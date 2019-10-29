**spring-cloud-hystrix-turbine**

1、引入jar包
-
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-turbine</artifactId>
    </dependency>
    
2、配置文件
-
    server:
      port: 8082
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      application:
        name: hystrix-dashboard-server
    
    management:
      endpoints:
        web:
          exposure:
            include: "*"
          cors:
            allowed-origins: "*"
            allowed-methods: "*"
    
    turbine:
      app-config: hystrix-dashboard-server, hystrix-dashboard-server-another  # 几个需要聚合的服务
      aggregator:
        clusterConfig: default
      clusterNameExpression: new String("default")
      combine-host: true
      instanceUrlSuffix:
        default: actuator/hystrix.stream
        
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    @RestController
    @EnableHystrix
    @EnableHystrixDashboard
    @EnableTurbine
    public class HystrixTurbineApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(HystrixTurbineApplication.class, args);
        }
    
    }
    
4、访问   http://localhost:8082/turbine.stream
-
    : ping
    data: {"rollingCountFallbackSuccess":0,"rollingCountFallbackFailure":0,"propertyValue_circuitBreakerRequestVolumeThreshold":40,"propertyValue_circuitBreakerForceOpen":false,"propertyValue_metricsRollingStatisticalWindowInMilliseconds":20000,"latencyTotal_mean":20,"rollingMaxConcurrentExecutionCount":2,"type":"HystrixCommand","rollingCountResponsesFromCache":0,"rollingCountBadRequests":0,"rollingCountTimeout":0,"propertyValue_executionIsolationStrategy":"THREAD","rollingCountFailure":0,"rollingCountExceptionsThrown":0,"rollingCountFallbackMissing":0,"threadPool":"{\"HystrixDashboardApplication$$EnhancerBySpringCGLIB$$30d9acd\":1,\"HystrixDashboardAnotherApplication$$EnhancerBySpringCGLIB$$f794e9d6\":1}","latencyExecute_mean":19,"isCircuitBreakerOpen":false,"errorCount":0,"rollingCountSemaphoreRejected":0,"group":"{\"HystrixDashboardApplication$$EnhancerBySpringCGLIB$$30d9acd\":1,\"HystrixDashboardAnotherApplication$$EnhancerBySpringCGLIB$$f794e9d6\":1}","latencyTotal":{"0":6,"99":35,"100":35,"25":6,"90":35,"50":6,"95":35,"99.5":35,"75":35},"requestCount":2,"rollingCountCollapsedRequests":0,"rollingCountShortCircuited":0,"propertyValue_circuitBreakerSleepWindowInMilliseconds":10000,"latencyExecute":{"0":6,"99":32,"100":32,"25":6,"90":32,"50":6,"95":32,"99.5":32,"75":32},"rollingCountEmit":0,"currentConcurrentExecutionCount":0,"propertyValue_executionIsolationSemaphoreMaxConcurrentRequests":20,"errorPercentage":0,"rollingCountThreadPoolRejected":0,"propertyValue_circuitBreakerEnabled":true,"propertyValue_executionIsolationThreadInterruptOnTimeout":true,"propertyValue_requestCacheEnabled":true,"rollingCountFallbackRejection":0,"propertyValue_requestLogEnabled":true,"rollingCountFallbackEmit":0,"rollingCountSuccess":2,"propertyValue_fallbackIsolationSemaphoreMaxConcurrentRequests":20,"propertyValue_circuitBreakerErrorThresholdPercentage":100,"propertyValue_circuitBreakerForceClosed":false,"name":"hello","reportingHosts":2,"propertyValue_executionIsolationThreadPoolKeyOverride":"null","propertyValue_executionIsolationThreadTimeoutInMilliseconds":2000,"propertyValue_executionTimeoutInMilliseconds":2000}
    
    : ping
    data: {"reportingHostsLast10Seconds":2,"name":"meta","type":"meta","timestamp":1570689856985}
    
    data: {"rollingCountFallbackSuccess":0,"rollingCountFallbackFailure":0,"propertyValue_circuitBreakerRequestVolumeThreshold":40,"propertyValue_circuitBreakerForceOpen":false,"propertyValue_metricsRollingStatisticalWindowInMilliseconds":20000,"latencyTotal_mean":20,"rollingMaxConcurrentExecutionCount":1,"type":"HystrixCommand","rollingCountResponsesFromCache":0,"rollingCountBadRequests":0,"rollingCountTimeout":0,"propertyValue_executionIsolationStrategy":"THREAD","rollingCountFailure":0,"rollingCountExceptionsThrown":0,"rollingCountFallbackMissing":0,"threadPool":"{\"HystrixDashboardApplication$$EnhancerBySpringCGLIB$$30d9acd\":1,\"HystrixDashboardAnotherApplication$$EnhancerBySpringCGLIB$$f794e9d6\":1}","latencyExecute_mean":19,"isCircuitBreakerOpen":false,"errorCount":0,"rollingCountSemaphoreRejected":0,"group":"{\"HystrixDashboardApplication$$EnhancerBySpringCGLIB$$30d9acd\":1,\"HystrixDashboardAnotherApplication$$EnhancerBySpringCGLIB$$f794e9d6\":1}","latencyTotal":{"0":6,"99":35,"100":35,"25":6,"90":35,"50":6,"95":35,"99.5":35,"75":35},"requestCount":0,"rollingCountCollapsedRequests":0,"rollingCountShortCircuited":0,"propertyValue_circuitBreakerSleepWindowInMilliseconds":10000,"latencyExecute":{"0":6,"99":32,"100":32,"25":6,"90":32,"50":6,"95":32,"99.5":32,"75":32},"rollingCountEmit":0,"currentConcurrentExecutionCount":0,"propertyValue_executionIsolationSemaphoreMaxConcurrentRequests":20,"errorPercentage":0,"rollingCountThreadPoolRejected":0,"propertyValue_circuitBreakerEnabled":true,"propertyValue_executionIsolationThreadInterruptOnTimeout":true,"propertyValue_requestCacheEnabled":true,"rollingCountFallbackRejection":0,"propertyValue_requestLogEnabled":true,"rollingCountFallbackEmit":0,"rollingCountSuccess":1,"propertyValue_fallbackIsolationSemaphoreMaxConcurrentRequests":20,"propertyValue_circuitBreakerErrorThresholdPercentage":100,"propertyValue_circuitBreakerForceClosed":false,"name":"hello","reportingHosts":2,"propertyValue_executionIsolationThreadPoolKeyOverride":"null","propertyValue_executionIsolationThreadTimeoutInMilliseconds":2000,"propertyValue_executionTimeoutInMilliseconds":2000}
    
5、访问  http://localhost:8081/hystrix
-
    输入http://localhost:8082/turbine.stream