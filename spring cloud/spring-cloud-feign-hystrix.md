**spring-cloud-ribbon-hystrix**

## 客户端配置
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
        <artifactId>spring-cloud-starter-openfeign</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
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
        name: feign-hystrix-server
    
    feign:
      hystrix:
        enabled: true
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    @EnableFeignClients
    @EnableHystrix
    public class FeignHystrixApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(FeignHystrixApplication.class, args);
        }
    
    }

4、定义Feign接口
-
    @FeignClient(value = "cloud-server", fallback = FeignHystrixError.class)
    public interface IFeignHystrix {
    
        @RequestMapping(value = "/ribbon",method = RequestMethod.GET)
        public String feign(@RequestParam(value = "name") String name);
    }

5、定义FeignHystrixError实现IFeignHystrix接口
-
    @Component
    public class FeignHystrixError implements IFeignHystrix{
        @Override
        public String feign(String name) {
            return "Sorry !!! " + name;
        }
    }

6、请求服务
-
    @RestController
    public class FeignController {
    
        @Autowired
        private IFeign feign;
    
        @RequestMapping("feign")
        public String feign(@RequestParam("name") String name) {
            return feign.feign(name);
        }
    }
       
## 服务端配置
1、 引入jar
-
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
2、配置文件
-
    server:
      port: 8763  # 8764
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      application:
        name: cloud-server

4、服务端
-
    @SpringBootApplication
    @EnableEurekaClient
    public class CloudServerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(CloudServerApplication.class, args);
        }
    }
    
-
    @RestController
    public class RibbonService {
    
        @Value("${server.port}")
        private String port;
    
        @RequestMapping(value = "ribbon", method = RequestMethod.GET)
        public String ribbon(@RequestParam("name") String name) {
            return "Hello, " + name + ", the port is " + port;
        }
    
    }
    
- 启动8763、8764两个服务端，请求客户端
-
        http://localhost:8765/feign?name=wujk
        ------------------------------------------- 
        Hello, wujk, the port is 8763
        Hello, wujk, the port is 8764
    
- 关闭服务
- 
        http://localhost:8765/feign?name=wujk
        ------------------------------------------- 
        Sorry !!!! wujk
    