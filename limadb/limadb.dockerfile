FROM prismagraphql/prisma:1.29
RUN "ls"
EXPOSE 4466
CMD [ "prisma" ]