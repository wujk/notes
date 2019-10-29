# spring-boot项目启动

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
    
###### 2、启动
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    
    @SpringBootApplication
    public class SpringBootFirstApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootFirstApplication.class, args);
        }
    }
    
###### 3、启动来看看springboot在启动的时候为我们注入了哪些bean
    @Bean
   	public CommandLineRunner commandLineRunner(ApplicationContext ctx) {
   		return args -> {
   
   			System.out.println("Let's inspect the beans provided by Spring Boot:");
   
   			String[] beanNames = ctx.getBeanDefinitionNames();
   			Arrays.sort(beanNames);
   			for (String beanName : beanNames) {
   				System.out.println(beanName);
   			}
   
   		};
   	}
 
  

      