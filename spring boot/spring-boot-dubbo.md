# spring-boot-dubbo

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>com.alibaba.boot</groupId>
         <artifactId>dubbo-spring-boot-starter</artifactId>
         <version>0.2.0</version>
     </dependency>
     <dependency>
         <groupId>org.apache.zookeeper</groupId>
         <artifactId>zookeeper</artifactId>
         <version>3.4.14</version>
     </dependency>
     <dependency>
         <groupId>com.wujk.spring</groupId>
         <artifactId>project</artifactId>
         <version>1.0-SNAPSHOT</version>
         <scope>compile</scope>
     </dependency>

    
###### 2、dubbo配置
    dubbo.application.name=provider
    dubbo.registry.address=zookeeper://127.0.0.1:2181
    dubbo.protocol.name=dubbo
    dubbo.protocol.port=20880
    
###### 3、服务端启动配置
    @SpringBootApplication
    @EnableDubbo
    public class DubboServiceSpringBootApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(DubboServiceSpringBootApplication.class, args);
        }
    }
    
###### 4、服务
    @Service
    public class DubboService implements IDubboService {
    
        @Override
        public String hello(String name) {
            return "hello, " + name;
        }
    }
    

###### 5、客户端配置基本与服务端一致（jar包相同，启动注解相同，配置文件需要修改）
    dubbo.application.name=client
    dubbo.registry.address=zookeeper://127.0.0.1:2181
    dubbo.protocol.name=client
    
    
    @RestController
    public class DubboController {
    
        @Reference
        private IDubboService dubboService;
    
        @GetMapping("hello")
        public String hello(@RequestParam("name")String name) {
            return dubboService.hello(name);
        }
    
    }
    
