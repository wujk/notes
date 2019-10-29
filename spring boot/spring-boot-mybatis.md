# spring-boot-mybatis

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.mybatis.spring.boot</groupId>
         <artifactId>mybatis-spring-boot-starter</artifactId>
         <version>2.1.0</version>
     </dependency>
     <dependency>
         <groupId>mysql</groupId>
         <artifactId>mysql-connector-java</artifactId>
         <version>5.1.36</version>
         <scope>runtime</scope>
     </dependency>
    
###### 2、数据库配置
    spring.datasource.driver-class-name=com.mysql.jdbc.Driver
    spring.datasource.url=jdbc:mysql://192.168.140.215:3306/hr_saas
    spring.datasource.username=root
    spring.datasource.password=111111
    
###### 3、sql查询
    @Mapper
    public interface AccountMapper {
    
        @Select("select uid from ACCOUNT limit 1")
        public List<Account> list();
    }