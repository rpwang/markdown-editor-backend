import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = new DocumentBuilder()
    .setTitle('Markdown Editor API')
    .setDescription(
      `## Authentication\n\n` +
      `This API supports three authentication methods:\n` +
      `- **Local signup** — \`POST /auth/signup\`\n` +
      `- **Local login** — \`POST /auth/login\`\n` +
      `- **LDAP** — \`POST /auth/ldap/login\`\n\n` +
      `After login, use the returned \`accessToken\` as a Bearer token.`
    )
    .setVersion('1.0')
    .addTag('auth', 'Authentication — login, signup, OAuth, LDAP')
    .addTag('users', 'User management and role administration')
    .build();
  const documentFactory = () => SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, documentFactory);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();

