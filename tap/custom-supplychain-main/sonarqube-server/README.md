## setup 

```
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
```

```
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube
```

it will take long time... 

```
kubectl logs pod/sonarqube-sonarqube-0 -n sonarqube --all-containers -f

023.09.18 12:39:42 INFO  app[][o.s.a.ProcessLauncherImpl] Launch process[COMPUTE_ENGINE] from [/opt/sonarqube]: /opt/java/openjdk/bin/java -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Djava.io.tmpdir=/opt/sonarqube/temp -XX:-OmitStackTraceInFastThrow --add-opens=java.base/java.util=ALL-UNNAMED --add-exports=java.base/jdk.internal.ref=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.management/sun.management=ALL-UNNAMED --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED -Dcom.redhat.fips=false -Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError -Dhttp.nonProxyHosts=localhost|127.*|[::1] -cp ./lib/sonar-application-10.2.0.77647.jar:/opt/sonarqube/lib/jdbc/postgresql/postgresql-42.6.0.jar org.sonar.ce.app.CeServer /opt/sonarqube/temp/sq-process12303098109636107896properties
2023.09.18 12:39:43 ERROR web[][o.s.s.w.WebServiceEngine] Fail to process request http://100.96.3.162:9000/api/system/liveness
java.lang.IllegalStateException: Liveness check failed
	at org.sonar.server.platform.ws.LivenessActionSupport.checkliveness(LivenessActionSupport.java:56)
	at org.sonar.server.platform.ws.LivenessAction.handle(LivenessAction.java:51)
	at org.sonar.server.ws.WebServiceEngine.execute(WebServiceEngine.java:111)
	at org.sonar.server.platform.web.WebServiceFilter.doFilter(WebServiceFilter.java:84)
	at org.sonar.server.platform.web.MasterServletFilter$JavaxFilterAdapter.doFilter(MasterServletFilter.java:227)
	at org.sonar.server.platform.web.MasterServletFilter$GodFilterChain.doFilter(MasterServletFilter.java:198)
	at org.sonar.server.platform.web.MasterServletFilter$HttpFilterChainAdapter.doFilter(MasterServletFilter.java:241)
	at org.sonar.server.platform.web.SonarLintConnectionFilter.doFilter(SonarLintConnectionFilter.java:66)


WARNING: System::setSecurityManager will be removed in a future release
2023.09.18 12:39:45 INFO  ce[][o.s.p.ProcessEntryPoint] Starting Compute Engine
2023.09.18 12:39:45 INFO  ce[][o.s.ce.app.CeServer] Compute Engine starting up...
2023.09.18 12:39:46 WARN  app[][startup] ####################################################################################################################
2023.09.18 12:39:46 WARN  app[][startup] Default Administrator credentials are still being used. Make sure to change the password or deactivate the account.
2023.09.18 12:39:46 WARN  app[][startup] ####################################################################################################################
2023.09.18 12:39:46 INFO  web[][o.s.s.p.Platform] Web Server is operational
2023.09.18 12:39:48 INFO  ce[][o.s.d.DefaultDatabase] Create JDBC data source for jdbc:postgresql://sonarqube-postgresql:5432/sonarDB
2023.09.18 12:39:48 INFO  ce[][c.z.h.HikariDataSource] HikariPool-1 - Starting...
2023.09.18 12:39:48 INFO  ce[][c.z.h.p.HikariPool] HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection@5df0e76f
2023.09.18 12:39:48 INFO  ce[][c.z.h.HikariDataSource] HikariPool-1 - Start completed.
2023.09.18 12:39:53 INFO  ce[][o.s.s.p.ServerFileSystemImpl] SonarQube home: /opt/sonarqube
2023.09.18 12:39:54 INFO  ce[][o.s.c.c.CePluginRepository] Load plugins
2023.09.18 12:39:58 INFO  ce[][o.s.c.c.ComputeEngineContainerImpl] Running Community edition
2023.09.18 12:39:58 INFO  ce[][o.s.ce.app.CeServer] Compute Engine is started
2023.09.18 12:39:58 INFO  app[][o.s.a.SchedulerImpl] Process[ce] is up
2023.09.18 12:39:58 INFO  app[][o.s.a.SchedulerImpl] SonarQube is operational

```

update certificate.yml, httpproxy.yml for domain url.
```
spec:
  dnsNames:
  - sonar-server.h2o-2-22280.h2o.vmware.com ## TODO
```

update service.yml for loadbalancer IP
```
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.0.27 ## TODO update
```


apply
```
kubectl apply -f service.yml -n sonarqube
kubectl apply -f certificate.yml -n sonarqube
kubectl apply -f httpproxy.yml -n sonarqube
kubectl apply -f httpproxy-80.yml -n sonarqube 
```

check httpproxy.

```
kubectl get httpproxy -n sonarqube

NAME                     FQDN                                        TLS SECRET          STATUS   STATUS DESCRIPTION
sonarqube-httpproxy      sonar-server.h2o-2-22280.h2o.vmware.com     sonar-default-tls   valid    Valid HTTPProxy
sonarqube-httpproxy-80   sonar-server80.h2o-2-22280.h2o.vmware.com                       valid    Valid HTTPProxy
```

connect to portal: admin/admin
- http://sonar-server80.h2o-2-22280.h2o.vmware.com /projects/create?mode=manual
- https://sonar-server.h2o-2-22280.h2o.vmware.com 



#### quick testing for sonar scanner cli.

```
mkdir ./cacerts/
k get secrets -n sonarqube sonar-default-tls -o jsonpath='{.data.ca\.crt}' | base64 -d > ./cacerts/sonar_ca.crt
git clone https://github.com/myminseok/tanzu-java-web-app
docker pull sonarsource/sonar-scanner-cli

docker run  --rm \
    -v $PWD/cacerts:/tmp/cacerts \
    -v $PWD/tanzu-java-web-app:/usr/src \
    -e SONAR_HOST_URL='https://sonar-server.h2o-2-22280.h2o.vmware.com' \
    -e SONAR_PASSWORD='VMware1!' -e SONAR_LOGIN=admin \
    sonarsource/sonar-scanner-cli
```
and there should be error but it should be OK other than similar to SSLPeerUnverifiedException, PKIX failure
```
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
Warning: use -cacerts option to access cacerts keystore

Certificate was added to keystore
INFO: Scanner configuration file: /opt/sonar-scanner/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 5.0.1.3006
INFO: Java 17.0.8 Alpine (64-bit)
INFO: Linux 5.15.49-linuxkit-pr amd64
INFO: User cache: /opt/sonar-scanner/.sonar/cache

...
Caused by: java.lang.IllegalStateException: Fail to download sonar-scanner-engine-shaded-10.3.0.82913-all.jar to /opt/sonar-scanner/.sonar/cache/_tmp/fileCache11037789544637144048.tmp
...

```

#### optional POD security

https://kubernetes.io/docs/concepts/security/pod-security-standards/
https://raw.githubusercontent.com/kubernetes/website/main/content/en/examples/security/podsecurity-privileged.yaml

```
apiVersion: v1
kind: Namespace
metadata:
  name: my-privileged-namespace
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/enforce-version: latest
```

