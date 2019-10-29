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
        <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
    </dependency>
    
2、配置文件（application.yml）
-
    server:
      port: 8767
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      application:
        name: ribbon-hystrix-server
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    public class RibbonAplication {
    
        public static void main(String[] args) {
            SpringApplication.run(RibbonAplication.class, args);
        }
    
        @Bean
        @LoadBalanced
        RestTemplate restTemplate() {
            return new RestTemplate();
        }
    }
    
4、客户端请求
-
    @RestController
    public class RibbonHystrixController {
    
        @Autowired
        RestTemplate restTemplate;
    
        @RequestMapping("ribbon")
        @HystrixCommand(fallbackMethod = "hiError")
        public String ribbon(@RequestParam("name") String name) {
            return restTemplate.getForObject("http://cloud-server/ribbon?name="+name,String.class);
        }
    
        public String hiError(String name) {
            return "Sorry !!!! " + name;
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
        http://localhost:8765/ribbon?name=wujk
        ------------------------------------------- 
        Hello, wujk, the port is 8763
        Hello, wujk, the port is 8764
    
- 关闭服务
- 
        http://localhost:8765/ribbon?name=wujk
        ------------------------------------------- 
        Sorry !!!! wujk
    