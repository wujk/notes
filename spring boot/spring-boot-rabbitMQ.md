# spring-boot-redis

###### 1、 引入jar包
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
     </dependency>
     <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-amqp</artifactId>
     </dependency>

    
###### 2、数据库配置
    spring.rabbitmq.host=127.0.0.1
    spring.rabbitmq.port=5672
    spring.rabbitmq.username=guest
    spring.rabbitmq.password=guest
    
###### 3、消费者
    @Component
    public class Receiver {
    
        public void receiveMessage(String message) {
            System.out.println("receiveMessage " + message);
        }
    
    }
    
###### 4、消息监听容器
    @Configuration
    public class MessageListener {
    
        private String queueName = "message";
    
        @Bean
        Queue queue() {
            return new Queue(queueName, false);
        }
    
        @Bean
        TopicExchange exchange() {
            return new TopicExchange("spring-boot-exchange");
        }
    
        @Bean
        Binding binding(Queue queue, TopicExchange exchange) {
            return BindingBuilder.bind(queue).to(exchange).with(queueName);
        }
    
    
        @Bean
        SimpleMessageListenerContainer container(ConnectionFactory connectionFactory,
                                                 MessageListenerAdapter listenerAdapter) {
    
            SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
            container.setConnectionFactory(connectionFactory);
            container.setQueueNames(queueName);
            container.setMessageListener(listenerAdapter);
            return container;
        }
    
        @Bean
        MessageListenerAdapter listenerAdapter(@Autowired Receiver receiver) {
            return new MessageListenerAdapter(receiver, "receiveMessage");
        }
    
    }
    
###### 5、生产者
    @RestController
    public class Producer {
    
        @Autowired
        private RabbitTemplate rabbitTemplate;
    
        @RequestMapping(value = "send/{message}", method = RequestMethod.GET)
        public void send(@PathVariable String message) {
            System.out.println("send " + message);
            rabbitTemplate.convertAndSend("message", message);
        }
    
    }
    
