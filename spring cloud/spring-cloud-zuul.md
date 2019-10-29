**spring-cloud-zuul**

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
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
    </dependency>
    
2、配置文件（application.yml）
-
    server:
      port: 8768
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      application:
        name: zuul-server
    
    zuul:
      routes:
        api-a:
          path: /api-a/**
          serviceId: ribbon-server
        api-b:
          path: /api-b/**
          serviceId: feign-server
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    @EnableZuulProxy
    public class ZuulServerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(ZuulServerApplication.class, args);
        }
    }
    
4、访问浏览器
- 
    http://localhost:8768/api-a/ribbon?name=wujk
    ------------------------------------------ 
        Hello, wujk, the port is 8763
 
    http://localhost:8768/api-b/feign?name=wujk
    ------------------------------------------ 
        Hello, wujk, the port is 8763
        
5、 ZuulFilter
- filterType：返回一个字符串代表过滤器的类型，在zuul中定义了四种不同生命周期的过滤器类型，具体如下：
     - pre：路由之前
     - routing：路由之时
     - post： 路由之后
     - error：发送错误调用
- filterOrder：过滤的顺序
- shouldFilter：这里可以写逻辑判断，是否要过滤，本文true,永远过滤。
- run：过滤器的具体逻辑。可用很复杂，包括查sql，nosql去判断该请求到底有没有权限访问。



   