# spring-boot-restTemplate

###### 1、引入jar包
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
###### 2、注入RestTemplate
    @SpringBootApplication
    public class springbootrestTemplate {
    
        public static void main(String[] args) {
            SpringApplication.run(springbootrestTemplate.class, args);
        }
    
        @Bean
        public RestTemplate restTemplate(RestTemplateBuilder builder) {
            return builder.build();
        }
    
        @Bean
        public CommandLineRunner commandLineRunner(RestTemplate restTemplate) {
            return args -> {
                String quote = restTemplate.getForObject(
                        "http://localhost:8083/info", String.class);
                System.out.println(quote);
            };
        }
    }