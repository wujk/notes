# spring-boot-restdocs

###### 1、引入jar包
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.restdocs</groupId>
            <artifactId>spring-restdocs-mockmvc</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.asciidoctor</groupId>
                <artifactId>asciidoctor-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>generate-docs</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>process-asciidoc</goal>
                        </goals>
                        <configuration>
                            <sourceDocumentName>index.adoc</sourceDocumentName>
                            <backend>html</backend>
                            <attributes>
                                <snippets>${project.build.directory}/snippets</snippets>
                            </attributes>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
    
###### 2、测试类
    @RunWith(SpringRunner.class)
    @WebMvcTest(RestdocsController.class)
    @ContextConfiguration(classes = {RestdocsController.class})  // 同一个包下可以不写
    @AutoConfigureRestDocs(outputDir = "target/snippets")
    public class RestDocsTest {
    
        @Autowired
        private MockMvc mockMvc;
    
        @Test
        public void shouldReturnDefaultMessage() throws Exception {
            this.mockMvc.perform(get("/hello")).andDo(print()).andExpect(status().isOk())
                    .andExpect(content().string(containsString("wujk")))
                    .andDo(document("home1"));
        }
    
        @Test
        public void restDocsTest() throws Exception {
            this.mockMvc.perform(get("/restdocs")).andDo(print()).andExpect(status().isOk())
                    .andExpect(content().string(containsString("Hello Restdocs")))
                    .andDo(document("home2"));
        }
    
    }
    
###### 3、测试后会生成目录
    ── target
        └── snippets
            └── home1
                └── httpie-request.adoc
                └── curl-request.adoc
                └── http-request.adoc
                └── http-response.adoc
            └── home2
                └── httpie-request.adoc
                └── curl-request.adoc
                └── http-request.adoc
                └── http-response.adoc
                
###### 4、创建一个新文件src/main/asciidoc/index.adoc：
    = Learn Spring REST Docs
    :toc: left
    
    Learn how to use Spring REST Docs based on Spring Boot2 and JUnit5.
    
    == /hello接口
    
    .request
    include::{snippets}/home1/http-request.adoc[]
    
    .response
    include::{snippets}/home1/http-response.adoc[]
    
    == /restdocs接口
    
    .request
    include::{snippets}/home2/http-request.adoc[]
    
    .response
    include::{snippets}/home2/http-response.adoc[]
    
###### 5、在target/generated-docs生成html
    mvn package     
 
  

      