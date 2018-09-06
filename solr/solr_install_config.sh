#!/bin/bash
if [[ $# < 5 ]] ; then
    echo "Usage: $0 1.host_name 2.solr_home_path 3.tomcat_solr_path 4.solr_port 5.zk_hosts"
    exit
fi

if [[ "root" != `whoami` ]] ; then
    echo "Run me as root please!"
    exit
fi

# 修改 tomcat 端口号
sed -i "s/8080/$4/" $3/conf/server.xml

# 关联 solr 及 solrhome 修改 web.xml
rm -rf $3/webapps/solr/WEB-INF/web.xml
touch $3/webapps/solr/WEB-INF/web.xml

cat << EOF >> $3/webapps/solr/WEB-INF/web.xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd"
         version="2.5"
         metadata-complete="true"
>


  <!-- Uncomment if you are trying to use a Resin version before 3.0.19.
    Their XML implementation isn't entirely compatible with Xerces.
    Below are the implementations to use with Sun's JVM.
  <system-property javax.xml.xpath.XPathFactory=
             "com.sun.org.apache.xpath.internal.jaxp.XPathFactoryImpl"/>
  <system-property javax.xml.parsers.DocumentBuilderFactory=
             "com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl"/>
  <system-property javax.xml.parsers.SAXParserFactory=
             "com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl"/>
   -->

  <!-- People who want to hardcode their "Solr Home" directly into the
       WAR File can set the JNDI property here...
   -->

    <env-entry>
       <env-entry-name>solr/home</env-entry-name>
       <env-entry-value>$2</env-entry-value>
       <env-entry-type>java.lang.String</env-entry-type>
    </env-entry>

  <!-- Any path (name) registered in solrconfig.xml will be sent to that filter -->
  <filter>
    <filter-name>SolrRequestFilter</filter-name>
    <filter-class>org.apache.solr.servlet.SolrDispatchFilter</filter-class>
    <!--
    Exclude patterns is a list of directories that would be short circuited by the
    SolrDispatchFilter. It includes all Admin UI related static content.
    NOTE: It is NOT a pattern but only matches the start of the HTTP ServletPath.
    -->
    <init-param>
      <param-name>excludePatterns</param-name>
      <param-value>/partials/.+,/libs/.+,/css/.+,/js/.+,/img/.+,/tpl/.+</param-value>
    </init-param>
  </filter>

  <filter-mapping>
    <!--
      NOTE: When using multicore, /admin JSP URLs with a core specified
      such as /solr/coreName/admin/stats.jsp get forwarded by a
      RequestDispatcher to /solr/admin/stats.jsp with the specified core
      put into request scope keyed as "org.apache.solr.SolrCore".

      It is unnecessary, and potentially problematic, to have the SolrDispatchFilter
      configured to also filter on forwards.  Do not configure
      this dispatcher as <dispatcher>FORWARD</dispatcher>.
    -->
    <filter-name>SolrRequestFilter</filter-name>
    <url-pattern>/*</url-pattern>
  </filter-mapping>

  <servlet>
    <servlet-name>LoadAdminUI</servlet-name>
    <servlet-class>org.apache.solr.servlet.LoadAdminUiServlet</servlet-class>
  </servlet>

  <!-- Remove in Solr 5.0 -->
  <!-- This sends SC_MOVED_PERMANENTLY (301) for resources that changed in 4.0 -->
  <servlet>
    <servlet-name>RedirectOldAdminUI</servlet-name>
    <servlet-class>org.apache.solr.servlet.RedirectServlet</servlet-class>
    <init-param>
      <param-name>destination</param-name>
      <param-value>${context}/#/</param-value>
    </init-param>
  </servlet>

  <servlet>
    <servlet-name>RedirectOldZookeeper</servlet-name>
    <servlet-class>org.apache.solr.servlet.RedirectServlet</servlet-class>
    <init-param>
      <param-name>destination</param-name>
      <param-value>${context}/admin/zookeeper</param-value>
    </init-param>
  </servlet>

  <servlet>
    <servlet-name>RedirectLogging</servlet-name>
    <servlet-class>org.apache.solr.servlet.RedirectServlet</servlet-class>
    <init-param>
      <param-name>destination</param-name>
      <param-value>${context}/#/~logging</param-value>
    </init-param>
  </servlet>

  <servlet>
    <servlet-name>SolrRestApi</servlet-name>
    <servlet-class>org.restlet.ext.servlet.ServerServlet</servlet-class>
    <init-param>
      <param-name>org.restlet.application</param-name>
      <param-value>org.apache.solr.rest.SolrSchemaRestApi</param-value>
    </init-param>
  </servlet>

  <servlet-mapping>
    <servlet-name>RedirectOldAdminUI</servlet-name>
    <url-pattern>/admin/</url-pattern>
  </servlet-mapping>
  <servlet-mapping>
    <servlet-name>RedirectOldAdminUI</servlet-name>
    <url-pattern>/admin</url-pattern>
  </servlet-mapping>
  <servlet-mapping>
    <servlet-name>RedirectOldZookeeper</servlet-name>
    <url-pattern>/zookeeper.jsp</url-pattern>
  </servlet-mapping>
  <servlet-mapping>
    <servlet-name>RedirectOldZookeeper</servlet-name>
    <url-pattern>/zookeeper</url-pattern>
  </servlet-mapping>
  <servlet-mapping>
    <servlet-name>RedirectLogging</servlet-name>
    <url-pattern>/logging</url-pattern>
  </servlet-mapping>

  <servlet-mapping>
    <servlet-name>LoadAdminUI</servlet-name>
    <url-pattern>/index.html</url-pattern>
  </servlet-mapping>

  <servlet-mapping>
    <servlet-name>SolrRestApi</servlet-name>
    <url-pattern>/schema/*</url-pattern>
  </servlet-mapping>

  <mime-mapping>
    <extension>.xsl</extension>
    <!-- per http://www.w3.org/TR/2006/PR-xslt20-20061121/ -->
    <mime-type>application/xslt+xml</mime-type>
  </mime-mapping>

  <welcome-file-list>
    <welcome-file>index.html</welcome-file>
  </welcome-file-list>

  <!-- Get rid of error message -->
<!--
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>Disable TRACE</web-resource-name>
      <url-pattern>/</url-pattern>
      <http-method>TRACE</http-method>
    </web-resource-collection>
    <auth-constraint/>
  </security-constraint>
  <security-constraint>
    <web-resource-collection>
      <web-resource-name>Enable everything but TRACE</web-resource-name>
      <url-pattern>/</url-pattern>
      <http-method-omission>TRACE</http-method-omission>
    </web-resource-collection>
  </security-constraint>
-->
</web-app>
EOF

# 配置 solrhome 下 solr.xml
rm -rf $2/solr.xml
touch $2/solr.xml

cat << EOF >> $2/solr.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!--
 Licensed to the Apache Software Foundation (ASF) under one or more
 contributor license agreements.  See the NOTICE file distributed with
 this work for additional information regarding copyright ownership.
 The ASF licenses this file to You under the Apache License, Version 2.0
 (the "License"); you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

<!--
   This is an example of a simple "solr.xml" file for configuring one or
   more Solr Cores, as well as allowing Cores to be added, removed, and
   reloaded via HTTP requests.

   More information about options available in this configuration file,
   and Solr Core administration can be found online:
   http://wiki.apache.org/solr/CoreAdmin
-->

<solr>

  <solrcloud>

    <str name="host">$1</str>
    <int name="hostPort">$4</int>
    <str name="hostContext">${hostContext:solr}</str>

    <bool name="genericCoreNodeNames">${genericCoreNodeNames:true}</bool>

    <int name="zkClientTimeout">${zkClientTimeout:30000}</int>
    <int name="distribUpdateSoTimeout">${distribUpdateSoTimeout:600000}</int>
    <int name="distribUpdateConnTimeout">${distribUpdateConnTimeout:60000}</int>
    <str name="zkCredentialsProvider">${zkCredentialsProvider:org.apache.solr.common.cloud.DefaultZkCredentialsProvider}</str>
    <str name="zkACLProvider">${zkACLProvider:org.apache.solr.common.cloud.DefaultZkACLProvider}</str>

  </solrcloud>

  <shardHandlerFactory name="shardHandlerFactory"
    class="HttpShardHandlerFactory">
    <int name="socketTimeout">${socketTimeout:600000}</int>
    <int name="connTimeout">${connTimeout:60000}</int>
  </shardHandlerFactory>

</solr>
EOF

# 修改 tomcat 的 catalina.sh 文件，关联 solr 和 zookeeper
sed -i 'N;288aJAVA_OPTS="-DzkHost='$5'"' $3/bin/catalina.sh