# Ex02: Scaling

With a much higher volume of incoming data, the solution implemented in ex01 would face a lot of scalability issues, among others:

- Querying a relational database with tables that contain 100M rows, even with the right indexes, might be relatively slow. Plus the query would have to be executed again for every new insert in the database, which would be suboptimal.

- Relying on 3rd party service for synchronous reverse geocoding might introduce stability issues and jeopardize our application stability and response time.

Here is an example of real time data flow, as an alternative architecture idea that might be adapted to such scaling issues.



### Main steps

*(in red on the schema)*

1. A producer sends new job offers, as distinct messages in a Kafka topic (*topic1*).

2. Using Kafka Stream, the geolocation data is processed, reverse geocoded, and the enriched (and filtered data) is sent to a new topic (*topic2*).
   I'm not very familiar with the Kafka Stream ecosystem, but here an exemple of custom implemented reversed geolocation for Kafka Stream, related in this article: https://lenses.io/blog/2020/12/geo-spatial-sql-data-processing-for-apache-kafka/
   In our case, if we assume that the end goal is only to display a breakdown of job offers count per category and continent; the messages in topic2 could have this structure:

```json
{
    action: "increment"/"decrement",
    category: "category name",
    continent: "continent"
}
```



3. Using Kafka Connect (and perhaps Kafka Stream), each event updates the count for the given category and continent, and the result is stored in a Redis store.

4. A Ruby Web Appplication fetches the data directly from the Redis database and displays the result to the client.



### Optional steps

*(in green on the schema)*

5. Using Kafka Connect, every incoming job offer could also be written in a relational database like Postgres, and be used by other services.

6. Instead of steps 3 and 4, a consumer could be subscribed to the *topic2* and be responsible for triggering the services required for data processing before the final display of the result.

### Advantages

- Scalability
  Easy to scale up vertically or horizontally.

- Clean decoupling
