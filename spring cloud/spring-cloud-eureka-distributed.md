**spring-cloud-eureka**

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
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
    </dependencies>
    
2、配置文件（bootstrap.yml而不是application.yml）
-
    # 服务1（bootstrap-master.yml）
    server:
      port: 8760
    
    eureka:
      instance:
        #prefer-ip-address: true  # 把真实ip注册到eureka
        hostname: peer1
      client:
        registerWithEureka: true
        fetchRegistry: false
        serviceUrl:
          defaultZone: http://peer2:8759/eureka/, http://peer3:8758/eureka/
    
    spring:
      application:
        name: eurka-server
        
-       
    # 服务2（bootstrap-slave.yml）   
     server:
       port: 8759
     
     eureka:
       instance:
        # prefer-ip-address: true  # 把真实ip注册到eureka
         hostname: peer2
       client:
         registerWithEureka: true
         fetchRegistry: false
         serviceUrl:
           defaultZone: http://peer1:8760/eureka/, http://peer3:8758/eureka/
     
     spring:
       application:
         name: eurka-server
   
-
    #服务3（bootstrap-slave1.yml）
    server:
      port: 8758
    
    eureka:
      instance:
        #prefer-ip-address: true  # 把真实ip注册到eureka
        hostname: peer3
      client:
        registerWithEureka: true
        fetchRegistry: false
        serviceUrl:
          defaultZone: http://peer1:8760/eureka/, http://peer2:8759/eureka/
    
    spring:
      application:
        name: eurka-server
        
3、启动
-
    @SpringBootApplication
    @EnableEurekaServer
    public class EurekaServerApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(EurekaServerApplication.class, args);
        }
    }
    
    
4、客户端注册配置
-
    server:
      port: 8762
    
    eureka:
      client:
        serviceUrl:
          defaultZone: http://peer1:8758/eureka/,http://peer2:8759/eureka/,http://peer3:8760/eureka/
      instance:
        prefer-ip-address: true  # 把真实ip注册到eureka
    
    spring:
      application:
        name: client-distributed
    
    