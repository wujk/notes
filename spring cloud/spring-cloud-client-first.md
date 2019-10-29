**spring-cloud-client-first**

1、引入jar包
- 
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.6.RELEASE</version>
        <relativePath /> <!-- lookup parent from repository -->
    </parent>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>
    
2、配置文件（application.yml）
-
    server:
      port: 8762
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://localhost:8761/eureka/
    
    spring:
      application:
        name: client-first
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaClient
    public class ClientFirstApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(ClientFirstApplication.class, args);
        }
    
    }
    