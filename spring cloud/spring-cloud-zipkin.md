**spring-cloud-zipkin**

# 配置 zipkin 服务
- 下载地址：https://dl.bintray.com/openzipkin/maven/io/zipkin/java/zipkin-server/
- java -jar zipkin-server-2.12.9-exec.jar 启动zipkin服务
- 访问 http://localhost:9411

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
        <artifactId>spring-cloud-starter-zipkin</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-openfeign</artifactId>
    </dependency>
    
2、配置文件（application.yml） 3个服务
-
    server:
      port: 8700
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    spring:
      zipkin:
        base-url: http://localhost:9411
    
      application:
        name: zipkin-begin-server
        
-
    server:
      port: 8701
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      zipkin:
        base-url: http://localhost:9411
      application:
        name: zipkin-mid-server
        
-
    server:
          port: 8702
        
        eureka:
          client:
            serviceUrl:
              defaultZone: http://localhost:8761/eureka/
        
        spring:
          zipkin:
            base-url: http://localhost:9411
          application:
            name: zipkin-end-server
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    @EnableFeignClients
    public class ZipkinBeginApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(ZipkinBeginApplication.class, args);
        }
    
        @Bean
        public Sampler defaultSampler() {  // 配置
            return Sampler.ALWAYS_SAMPLE;
        }
    }
    
4、用feign请求测试
-
    @RestController
    public class ZipkinController {
    
        @Autowired
        private IZipkin zipkin;
    
        @RequestMapping("zipkin")
        public String feign(@RequestParam("name") String name) {
            return zipkin.zipkin(name);
        }
    }
       
-    
    @FeignClient(value = "zipkin-mid-server")
    public interface IZipkin {
    
        @RequestMapping(value = "/zipkin",method = RequestMethod.GET)
        public String zipkin(@RequestParam(value = "name") String name);
    }

5、请求接口
-
    http://localhost:8700/zipkin?name=wujk
    ---------------------------------------
    Hello, wujk, the port is 8763

    
6、访问http://localhost:9411 查看调用过程
-
    
    
    