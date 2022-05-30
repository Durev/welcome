# Ex01: Explanations

Here are some detailed explanations on the design and implementation choices behind the ex01 solution.



## General approach

In a different context where the code could have benefitted from being reusable, I probably would have packaged this differently, for instance as a Rails engine with built-in views to visualize the results, or as a standard Ruby gem.

In the context of this exercice and to keep it as simple as possible, I chose to do a simple Ruby application instead.

I also chose to lean on existing Ruby libraries for common problems that weren't specific to the business logic of this exercice.



## Data storage, import and processing

Considering the structure and low volume of data, and the processing required to arrive to the desired output, I think that the simplest approach was to import the CSV input data into a relational database, enrich it with the desired information (continents) and compute the results.

For the needs of this exercice, and for small and medium sized tables (< 1M - 10M rows) relational databases offer a good compromise between simplicity of use, performance and easy integration within a Ruby application.



**RDBMS**

In order to avoid any compatibility issues with a RDBMS, I decided to use SQLite as it is quite portable, lightweight and easy to setup. For a production grade application, I might have picked another system, for instance PostgreSQL or MySQL.



**ORM**

ActiveRecord provides all the functionalities we need here, including a simple Ruby DSL to import, update and query the relevant data. It was my go-to choice as it is quite popular in the Rails ecosystem and I'm very familiar with it.



**Tasks automation**

I chose Rake to provide an interface for ActiveRecord based tasks and custom tasks.



**Data import step**

- As we don’t need all the attributes present in the input files (contract_type, name…); I decided to ignore the extraneous data not needed for this exercice. This meant filtering out the unwanted data during the import step.
  (cf. `data:load_professions` and `data:load_job_offers` tasks)

- These 2 tasks should be able to parse large CSV files, as they process the file line by line (with `CSV.foreach`), and the `job_offers` upsert in database is automatically split in batches (in the `data:load_job_offers` task).

- As SQLite does not support enum types, I decided to ignore any validation on the data for the `category_name` column. A CHECK CONSTRAINT might have done the job here.

- I arbitrarily decided to keep the data with NULL values for geolocation (`job_offers`) or category name (`professions`) during the import phase.
  It could have been equally efficient to ignore this data in the import step and use a NOT NULL constraint in database for better data consistency.



## (Reverse) Geocoding

**Design**

Several approaches have been considered for this step (cf. 'Alternative design' below).

Overall I decided to use a call to a 3rd party Web API, to reverse all the geolocations provided, initially thinking that it would be a very straightforward way to obtain the continent.

If I had to start all over again from scratch, this probably would not be my first choice anymore though.



**Reverse geocoding service**

When looking for a geocododing service, I mainly considered these criteria:

- Reverse geocoding feature

- Free tier

- High limit for free tier or batch synchronous reverse geocoding. For instance, [geoapify.com](http://geoapify.com/) provides batch geocoding where the first call to the API creates a background job, and requires to handle the callback logic with the given job id. This could work but introduces unecessary complexity here.

- If possible, ability to consume the API without signup and the need to setup an API key.



When starting the integration, I thought most services would provide the continent in the result data, but it turns out that I couldn't find a service that provided the continent **and** matched all the above criteria.



**Wrapper gem**

I quicky stumbled open the [geocoder](https://github.com/alexreisner/geocoder) gem, that offers multiple advantages for geocoding and reverse geocoding tasks:

- Integrates with multiple services, and provides a very convenient abstraction layer around all the HTTP client that would otherwise have to be configured according to API specificities for every service.

- Among others, flawlessly integrates with the [Nominatim / OpenStreetMap API](https://nominatim.org/release-docs/develop/api/Overview/).

- Good integration with ActiveRecord.

- Possible to "batch" the reverse geocoding (even though it turns out this might result in multiple single API calls depending on the services - I initially mistakenly thought it would be easier to batch the API calls)

- Comes with convenient defaults settings for configuration.



**Enriching job_offers table with continent**

After beginning the implementation, I realized that most geocoding services do not provide a continent classification.

(The main reason being that the continent classification is somewhat arbitrary and there is no agreed upon standard for such delimitation).

At this point, I thought it was more time efficient to keep the existing logic (that could provide the country for all geolocated job_offers) and, using a static lookup table, to add an extra step to match countries to continents.

This Wikipedia page provides a convenient matchup table between ISO3166 country codes and continent codes: [List of sovereign states and dependent territories by continent (data file) - Wikipedia](https://en.wikipedia.org/wiki/List_of_sovereign_states_and_dependent_territories_by_continent_(data_file))

After a quick processing with my text editor, I added this in a config file (cf. `config/countries.yml`).

In the context of this exercice I did not carry a thorough control of the data and assumed it was reliable. Some countries are classified in several continents at once (e.g. Azerbaijan can be classified as being both part of Asia and Europe), so when loading the list I arbitrarily keep the last occurrence.



**Actual reverse geocoding**

My initial goal was to be able fetch the records that weren't reverse geocoded, send the geolocation data by batches to an external service API, and update the records in database with the matching country data.



The geocoder gem does feature [a built-in rake task](https://github.com/alexreisner/geocoder#batch-geocoding) for that purpose (`rake geocode:all CLASS=JobOffer REVERSE=true`) that will fetch only records that are not already reverse geocoded.

But if the interface might be assimilated to a batch action, the underlying logic actually consists of multiple single API calls to the service responsible for reverse geocoding.

In reality, this results in a strenously slow process, lasting ~ 1,5 hours for 5K records.

With more time available, this is undeniably the problem I would have solved for this implementation.



**Alternative design**

For the reverse geocoding step, during my initial conception and during my implementation, I considered other approaches here:

1. Using a db extension for geographic data support (e.g. Postgis or SpatiaLite) and import a set of data containing administrative areas (continents) to rely on for classification.
   This would allow to go without any 3rd party API call (no extra cost, no performance issues related to external API calls).
   It would be simpler to implement if the database was already using such an embedded extension.
   In the context of this test though, I judged it might be very time consuming to setup and a source of dependencies issues for other users (aka install hell).

2. Importing a dataset of polygons defining the delimitation of continents, and manually checking in which polygon a point (lat, lont) is included in.

3. Use another API allowing Batch Reverse geocoding, but requiring signup and for which you may have to pay for in order to have a quick service for ~5K records.



## Results output

This part is relatively simple once all the data is loaded and reverse geocoded as it comes down to just writing the right SQL query, which is quite straightforward and can be done in Ruby using ActiveRecord, and then format it in a readable structure.

I chose to use the [terminal-table](https://github.com/tj/terminal-table) to easily print the results in an ASCII table.

As for some other gems, it could be debated here is if it’s worth introducing an external dependency for this simple task, but I assumed it didn't brind a lot of value to reimplement this kind of "common" logic (aka reinventing the wheel).



## Caveats and potential for improvement

### Reverse geocoding step

The painfully obvious caveat of this implementation is the time required to actually reverse geocoded all the records.

Solving this while keeping the same approach would require using a service where batch reverse geocoding is available.

### Specs

Another of the biggest and most obvious flaws of this implementation is the total absence of unit tests or integration tests.

A good test suite here would at least implement some basic unit tests covering the data import logic, the interactions with the geocoder gem, and the computation of the results at the end.

This exercice being already significantly time consuming, I had to chose between finishing the implementation of a working solution, or adding specs (the latter requiring also to setup a test framework, eg. RSpec, configure it, and add a test database).

Though in a real application, I would not be comfortable deploying untested code in production.

### Lack of adaptability

In order to easily format the results, the profession categories list is “hardcoded” at one point. It is relatively open for extension, but if a new category is introduced in the dataset, and the category list hasn’t been updated, the table with the results output won’t dynamically adapt. In a more "real world" situation, it could be worth implementing a more dynamic solution.

### Notes

I’m usually not a big proponent for comments in Ruby code, but in the context of this technical test, it felt like the more natural way to provide some context and explanation for specific lines of code. Thus the few comments you might find in ex01 code.


