# spring-boot-jpa

###### 1、 引入jar包
     <!-- 其中spring-boot-starter-web不仅包含spring-boot-starter,还自动开启了web功能。 -->
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-data-jpa</artifactId>
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
    # 解决数据库表大小写敏感问题
    spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
    
###### 3、实体类配置
    @Entity
    @Table(name="ACCOUNT")
    public class Account implements Serializable {
    
    	private static final long serialVersionUID = 2152347032828776318L;
    
    	@Id
    	@Column(name="UID")
    	private String uid;
    
    	@Column(name="COMPANY_UID")
    	private String companyUid;
    
    	@Column(name="PHONE")
    	private String phone;
    
    	@Column(name="PASSWD")
    	private String passwd;
    
    	@Column(name="IP")
    	private String ip;
    
    	@Column(name="ENABLE")
    	private Integer enable;
    
    	@Column(name="BROWSER")
    	private String browser;
    
    	@Column(name="LOGINTIME")
    	private Long logintime;
    
    	@Column(name="GUIDE")
    	private Boolean guide;
    
    	@Column(name="CREATE_TIME")
    	private Long createTime;
    
    	@Column(name="CREATE_USER")
    	private String createUser;
    
    	@Column(name="UPDATE_TIME")
    	private Long updateTime;
    
    	@Column(name="UPDATE_USER")
    	private String updateUser;
   
###### 4、sql查询
    @Repository
    public interface AccountDao  extends JpaRepository<Account,String> {
    
    
    }