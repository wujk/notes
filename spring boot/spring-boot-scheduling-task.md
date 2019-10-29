**spring-boot-scheduling-task**

###### 1、引入jar包
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
###### 2、启动
    @SpringBootApplication
    @EnableScheduling
    public class SpringbootSchedulingTasksApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringbootSchedulingTasksApplication.class, args);
        }
    }
    
###### 3、任务
    @Component
    public class ScheduledTasks {
    
        @Scheduled(cron="0/2 * * * * ?")
        private void task() {
            System.out.println("task is running...");
        }
    
    }
 
  

      