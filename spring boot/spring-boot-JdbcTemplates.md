# spring-boot-JdbcTemplates

###### 1、 引入jar包
     <!-- 其中spring-boot-starter-web不仅包含spring-boot-starter,还自动开启了web功能。 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-jdbc</artifactId>
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
    @Repository
    public class AccountDao implements IAccountDao {
    
        @Autowired
        private JdbcTemplate jdbcTemplate;
    
        @Override
        public List<Account> list() {
            return jdbcTemplate.query("select * from ACCOUNT", new BeanPropertyRowMapper(Account.class));
        }
    }