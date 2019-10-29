# spring-boot-mail

###### 1、引入jar包
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-mail</artifactId>
    </dependency>
    
###### 2、配置邮箱
    spring.mail.host=smtp.qq.com
    spring.mail.username=1961700095@qq.com
    spring.mail.password=zsndryfsdmqrcjej
    spring.mail.port=25
    spring.mail.protocol=smtp
    spring.mail.default-encoding=UTF-8
    
###### 3、邮件服务类
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.core.io.FileSystemResource;
    import org.springframework.mail.SimpleMailMessage;
    import org.springframework.mail.javamail.JavaMailSenderImpl;
    import org.springframework.mail.javamail.MimeMessageHelper;
    import org.springframework.stereotype.Service;
    
    import javax.mail.internet.MimeMessage;
    import java.io.File;
    
    @Service
    public class MailService {
    
        @Autowired
        private JavaMailSenderImpl mailSender;
    
        public void sendTxtMail() {
            SimpleMailMessage simpleMailMessage = new SimpleMailMessage();
            // 设置收件人，寄件人
            simpleMailMessage.setTo(new String[] {"1021815383@qq.com"});
            simpleMailMessage.setFrom("1961700095@qq.com");
            simpleMailMessage.setSubject("Spring Boot Mail 邮件测试【文本】");
            simpleMailMessage.setText("这里是一段简单文本。");
            // 发送邮件
            mailSender.send(simpleMailMessage);
    
            System.out.println("邮件已发送");
        }
    
        /**
         * 发送包含HTML文本的邮件
         * @throws Exception
         */
        public void sendHtmlMail() throws Exception {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage);
            mimeMessageHelper.setTo("1021815383@qq.com");
            mimeMessageHelper.setFrom("1961700095@qq.com");
            mimeMessageHelper.setSubject("Spring Boot Mail 邮件测试【HTML】");
    
            StringBuilder sb = new StringBuilder();
            sb.append("<html><head></head>");
            sb.append("<body><h1>spring 邮件测试</h1><p>hello!this is spring mail test。</p></body>");
            sb.append("</html>");
    
            // 启用html
            mimeMessageHelper.setText(sb.toString(), true);
            // 发送邮件
            mailSender.send(mimeMessage);
    
            System.out.println("邮件已发送");
    
        }
    
        /**
         * 发送包含内嵌图片的邮件
         * @throws Exception
         */
        public void sendAttachedImageMail() throws Exception {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            // multipart模式
            MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage, true);
            mimeMessageHelper.setTo("1021815383@qq.com");
            mimeMessageHelper.setFrom("1961700095@qq.com");
            mimeMessageHelper.setSubject("Spring Boot Mail 邮件测试【图片】");
    
            StringBuilder sb = new StringBuilder();
            sb.append("<html><head></head>");
            sb.append("<body><h1>spring 邮件测试</h1><p>hello!this is spring mail test。</p>");
            // cid为固定写法，imageId指定一个标识
            sb.append("<img src=\"cid:imageId\"/></body>");
            sb.append("</html>");
    
            // 启用html
            mimeMessageHelper.setText(sb.toString(), true);
    
            // 设置imageId
            FileSystemResource img = new FileSystemResource(new File("E:/1.jpg"));
            mimeMessageHelper.addInline("imageId", img);
    
            // 发送邮件
            mailSender.send(mimeMessage);
    
            System.out.println("邮件已发送");
        }
    
        /**
         * 发送包含附件的邮件
         * @throws Exception
         */
        public void sendAttendedFileMail() throws Exception {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            // multipart模式
            MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage, true, "utf-8");
            mimeMessageHelper.setTo("1021815383@qq.com");
            mimeMessageHelper.setFrom("1961700095@qq.com");
            mimeMessageHelper.setSubject("Spring Boot Mail 邮件测试【附件】");
    
            StringBuilder sb = new StringBuilder();
            sb.append("<html><head></head>");
            sb.append("<body><h1>spring 邮件测试</h1><p>hello!this is spring mail test。</p></body>");
            sb.append("</html>");
    
            // 启用html
            mimeMessageHelper.setText(sb.toString(), true);
            // 设置附件
            FileSystemResource img = new FileSystemResource(new File("E:/1.jpg"));
            mimeMessageHelper.addAttachment("image.jpg", img);
    
            // 发送邮件
            mailSender.send(mimeMessage);
    
            System.out.println("邮件已发送");
        }
    
    }
    
###### 4、发送邮件测试
    @SpringBootApplication
    public class SpringBootMailApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootMailApplication.class, args);
        }
    
        @Bean
        public CommandLineRunner commandLineRunner(MailService service) {
            return args -> {
                System.out.println("start sendMail.....");
                service.sendTxtMail();
                service.sendHtmlMail();
                service.sendAttachedImageMail();
                service.sendAttendedFileMail();
                System.out.println("end sendMail.....");
            };
        }
    }
  

      