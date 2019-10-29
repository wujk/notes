# spring-boot-mybatis-tx

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
    mybatis.mapper-locations=classpath*:mybatis/*Mapper.xml   # Mapper配置
    mybatis.type-aliases-package=com.wujk.springbootmybatistx # 映射实体类
    
###### 3、sql查询
    @Mapper
    public interface AccountMapper {
    
         int insert(Account account);
    
         int insertSelective(Account account);
    
    }
    
###### 4、开启事务
    @RestController
    public class AccountController {
    
        @Autowired
        AccountMapper accountMapper;
    
        @RequestMapping("insert")
        @Transactional   // 事务
        public Integer insert(){
            Integer count = 0;
            Account account = new Account();
            account.setUid("1");
            count += accountMapper.insert(account);
            account = new Account();
            account.setUid("2");
            int a = 1/0;
            count += accountMapper.insertSelective(account);
            return  count;
        }
    
    }