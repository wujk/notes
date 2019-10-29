# spring-boot-restdocs

###### 1、引入jar包
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger2</artifactId>
        <version>2.6.1</version>
    </dependency>
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger-ui</artifactId>
        <version>2.6.1</version>
    </dependency>
    
###### 2、配置swagger2
    @Configuration
    @EnableSwagger2
    public class Swagger2Config {
    
        @Bean
        public Docket createRestApi() {
            return new Docket(DocumentationType.SWAGGER_2)
                    .apiInfo(apiInfo())
                    .select()
                    .apis(RequestHandlerSelectors.basePackage("com.wujk.springbootswagger2"))
                    .paths(PathSelectors.any())
                    .build();
        }
        private ApiInfo apiInfo() {
            return new ApiInfoBuilder()
                    .title("springboot利用swagger构建api文档")
                    .description("简单优雅的restfun风格，https://github.com/wujk/spring-boot-cloud/tree/master/project")
                    .termsOfServiceUrl("https://github.com/wujk/spring-boot-cloud/tree/master/project")
                    .version("1.0")
                    .build();
        }
    }
    
###### 3、注解
    @RestController
    @Api(value = "Swagger Learn", tags = {"book Api"})
    public class SwaggerController {
    
        private List<Book> books = new ArrayList<Book>();
    
        @RequestMapping(value = "/add", method = RequestMethod.PUT)
        @ApiOperation(value = "添加列表", notes = "添加列表")
        @ApiImplicitParam(name="book", value = "图书实体book", required = true, dataType = "Book")
        public String add(@RequestBody Book book) {
            books.add(book);
            return "ok";
        }
    
        @RequestMapping(value = "/list", method = RequestMethod.GET)
        @ApiOperation(value = "查询列表", notes = "查询列表")
        public List<Book> list() {
            return books;
        }
    }
    
###### 常用注解

    swagger通过注解表明该接口会生成文档，包括接口名、请求方法、参数、返回信息的等等。
    
    @Api：修饰整个类，描述Controller的作用
    @ApiOperation：描述一个类的一个方法，或者说一个接口
    @ApiParam：单个参数描述
    @ApiModel：用对象来接收参数
    @ApiProperty：用对象接收参数时，描述对象的一个字段
    @ApiResponse：HTTP响应其中1个描述
    @ApiResponses：HTTP响应整体描述
    @ApiIgnore：使用该注解忽略这个API
    @ApiError ：发生错误返回的信息
    @ApiImplicitParam：一个请求参数
    @ApiImplicitParams 多个请求参数
    
###### 启动工程
    访问：http://localhost:8080/swagger-ui.html ，就看到swagger-ui
 
  

      