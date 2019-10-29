# spring-boot-properties

###### 1、引入jar包
    <parent>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-parent</artifactId>
         <version>2.1.6.RELEASE</version>
         <relativePath /> <!-- lookup parent from repository -->
     </parent>
     
     <!-- 其中spring-boot-starter-web不仅包含spring-boot-starter,还自动开启了web功能。 -->
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency> 
     
###### 2、配置类加入注解
    @ConfigurationProperties(prefix="my")
    //@Component
    public class User {
    
        private String name;
        private int age;
        private int number;
        private String uuid;
        private int max;
        private String value;
        private String greeting;
 
- 只加入@ConfigurationProperties(prefix="my")会报警告“Not registered via @EnableConfigurationProperties or marked as Spring component less... (Ctrl+F1) Inspection info: Verifies @ConfigurationProperties setup. New in 2018.3” 解决方法：@Component注释打卡，不加不影响
                                           
###### 3、调用类加入注解
    @RestController
    //@EnableConfigurationProperties({User.class})
    public class UserController {
    
        @Value("${my.name}")
        private String name;
    
        @Value("${my.age}")
        private Integer age;
    
        @Autowired
        private User user;
    
        @RequestMapping("info")
        public String info() {
            return name + ":" + age;
        }
    
        @RequestMapping("user")
        public String user() {
            return user.toString();
        }
    }  

-    加入@EnableConfigurationProperties({User.class})这个注解，配置类@Component可以不加，配置类加了@Component，调用时可以不加@EnableConfigurationProperties({User.class})


###### 4、自定义配置文件如：test.properties （加入注解@PropertySource("classpath:test.properties")）
    @ConfigurationProperties(prefix="test.test")
    @PropertySource("classpath:test.properties")
    @Component
    public class UserInfo {
   
        private String name;
        private int age;
           
###### 5、多配置文件选择
    application-dev.yml
    application-sit.yml
    
    
    spring:
      profiles:
        active: sit #启用sit
    

   
    

    
 
  

      