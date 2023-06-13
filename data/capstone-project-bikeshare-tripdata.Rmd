---
title: "Case Study: How Does a Bike-Share Navigate Speedy Success?"
author: "Damian Lee"
date: "2023-05-17"
output: html_document
---

## Introduction

This is a Capstone Project for the Google Data Analytics Professional Certification where I will perform data analysis for a fictional bike-share company in order to help them attract more riders. Along the way, I will perform numerous real-world tasks of a junior data analyst by following the steps of the data analysis process: **Ask, Prepare, Process, Analyse, Share, and Act**.

### Scenario

>“You are a junior data analyst working in the marketing analyst team at Cyclistic, a bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximising the number of annual memberships. Therefore, your team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, your team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve your recommendations, so they must be backed up with compelling data insights and professional data visualisations.”

### About the company

In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

Until now, Cyclistic’s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members. 

Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, Moreno believes that maximising the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a very good chance to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs. 

Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the marketing analyst team needs to better understand how annual members and casual riders differ, why casual riders would buy a membership, and how digital media could affect their marketing tactics. Moreno and her team are interested in analysing the Cyclistic historical bike trip data to identify trends.

## Phase 1: Ask

### 1. Identify the business task

**The business tasks:**

1. Analyse rider's data to identify the usage patterns
2. Recommend marketing strategies aimed at converting riders into annual members

**The questions that guide the future marketing program:**

1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

### 2. Consider key stakeholders

**Primary Stakeholders:**

- **Cyclistic:** The bike-share program itself is a primary stakeholder as they are responsible for providing and managing the bike-share service.

- **Lily Moreno (Director of Marketing):** As the director of marketing, Lily Moreno plays a crucial role in developing marketing campaigns and initiatives to promote the bike-share program.

**Secondary Stakeholders:**

- **Cyclistic Marketing Analytics Team:** This team of data analysts supports the marketing efforts by collecting, analyzing, and reporting data that helps guide Cyclistic's marketing strategy.

- **Cyclistic Executive Team:** The executive team holds decision-making authority and is responsible for approving recommended marketing programs and ensuring the overall success of the bike-share program.

## Phase 2 : Prepare

### 1. Data source used

For the purposes of this case study, the data sets used are taken from [Divvy Bikes](https://divvy-tripdata.s3.amazonaws.com/index.html). 

The data sets formatted in CSV file and contain Cylistic’s historical trip data organised into several data sets, each containing information on bike rides taken by Cyclistic customers. The data sets include variables such as ride start and end times, start and end stations, rider type (casual rider or member), and rideable type.

### 2. Data bias and credibility

To address the related issues, the ROCCC framework (reliable, original, comprehensive, current, and cited) will be used to evaluate data sources.

**Reliable: **As stated on the Divvy website, any trips under 60 seconds in length that may have been false starts or attempts by users to re-dock a bike for safety precautions have been processed and eliminated. However, the data may not factor in weather and time of day, which could affect ride patterns.

**Original: **The data sets are a primary source that was made available by Cyclistic. under this [licence](https://ride.divvybikes.com/data-license-agreement).

**Comprehensive: **The data sets are appropriate and sufficiently answer the business questions. However, riders' personally identifiable information will not be permitted due to the data privacy issue. It means that it is not possible to link pass purchases to credit card numbers to determine whether casual riders reside in the Cyclistic service area or if they have bought multiple single passes. On top of that, it also limits the analysis to determine customers' age range and gender population, which could help in marketing strategies.

**Current: **The data sets are current; they started collecting them in 2020, and they are still updating the latest data sets in April 2023, which is the time of the analysis process documented.

**Cited: **
There are research papers that use the words "Divvy" and "Bikeshare", which could indicate the usage of the data sets; however, there is no citation about the data usage, which does not show a clear indication the data set has been cited and used in research.

## Phase 3 : Process

### 1. Data cleaning
Start by installing the required packages. If you have already installed and loaded packages required in this session, feel free to skip the code chunks in this step. This may take a few minutes to run, and you may get a pop-up window asking if you want to proceed. Click yes to continue installing the packages. 

```{r install packages, echo=TRUE, eval=FALSE}
install.packages("tidyverse")
install.packages("lubridate")
install.packages("ggplot2")
```

Once a package is installed, you can load it by running the `library()` function with the package name inside the parentheses:
```{r load packages, echo=TRUE}
library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)  #helps visualize data
```

The `fread()` function from the `data.table` packages is generally faster and more efficient than using `read_csv()`. Therefore, the written function `combine.divvy.trip.data`[^1] is used to do so, and each data set (May 2022 to April 2023) is combined with `binds_row()`. The total observation is 5,859,061.
```{r load data set with `combine.divvy.trip.data()`, message=FALSE}
source("../scripts/functions.R")
tripdata_df <- combine.divvy.trip.data()

# Show total observations
nrow(tripdata_df)

print(head(tripdata_df),row.names = FALSE)
```
[^1]: The `combine.divvy.trip.data` function was inspired by the work of [Peter Carbonetto](https://stephenslab.github.io/wflow-divvy/first-glance.html).


**Up next, I will explore several problems:**

1. In the "member_casual" column, there are annual members ("member") and casual riders ("casual"). I will explore the data sets further.
2. The data can only be aggregated at the ride level, which is too granular. Having some additional columns of data, such as day, month, and year, that provide additional opportunities to aggregate the data would be helpful for analysis later on.
3. I will need to add a calculated field for the length of the ride.
4. There are some rides where trip duration shows up as negative, and I will explore how to address these rides. In addition, we will also address the potential for false starts.

I begin by exploring the number of rides based on "member" and "casual". The `summarise()` function creates a new data frame and returns one row for each variable in `group_by()`. Hence, it shows a summary based on "member_casual", where there are only two variables, "member" and "casual".

Adding both "member" and "casual" together, they should add up to the total of all observations (5,859,061). This is correct in this case.
```{r Summarise member_casueal count}
tripdata_df %>% 
  group_by(member_casual) %>% 
  summarise(count=n()) %>% 
  print()
```

Secondly, I want to add columns that list the date, month, day, and year of each ride. This will allow me to aggregate ride data based on month, day, or year. The `format()` function looks into the second arguments such as "%m", "%d", "%Y" and "%A", to return based on their symbols from `date` in `tripdata_df`.
```{r add columns that list the date, month, day, and year of each ride}
tripdata_df$date <- as.Date(tripdata_df$started_at) #The default format is yyyy-mm-dd
tripdata_df <- tripdata_df %>%
  mutate(month = month(started_at),
         day = day(started_at),
         year = year(started_at),
         day_of_week = wday(started_at))
head(tripdata_df)

```

The third is to calculate the length of the ride. Using the `difftime()` function, the difference between `started_at` and `ended_at` will returns the length of the ride.
```{r Add a "ride_length" calculation to tripdata_df (in seconds)}
# Add a "ride_length" calculation to tripdata_df (in seconds)
tripdata_df$ride_length <- difftime(tripdata_df$ended_at, 
                                 tripdata_df$started_at, units = "secs")

# Inspect the structure of the columns
str(tripdata_df)
```

In the previous code chunks, the `str()` function shows the structure of the `tripdata_df`. On the last column, "ride_length", it shows `difftime` instead of numeric. I will convert them to numeric so that I can run calculations on the data.
```{r converting ride_length from difftime to numeric}
tripdata_df$ride_length <- as.numeric(as.character(tripdata_df$ride_length))
is.numeric(tripdata_df$ride_length)
```


The last problem I need to address is the data consistency to remove "bad" data. Stated on [Divvy website](https://ride.divvybikes.com/system-data) about the data sets:

>The data has been processed to remove trips that are taken by staff as they service and inspect the system; and any trips that were below 60 seconds in length (potentially false starts or users trying to re-dock a bike to ensure it was secure).

To validate this, the `ride_length` column that was added earlier can help us check trip data that is below 60 seconds by using the `filter()` function.
```{r check trip below 60 seconds}
# Check number of rows in the trip below 60 secs
tripdata_df %>% 
  filter(ride_length < 60) %>% 
  nrow()
```
By removing trips that are below 60 seconds, I am directly removing "bad" data that could potentially skews the ride pattern. Ultimately, I'm removing data that show negative value in `ride_length` and also the potential false start that below 60 seconds.
```{r remove trip below 60 secs}
# We also remove below 60 secs for false start
tripdata_df <- tripdata_df[!(tripdata_df$ride_length < 60),]

# Check number of rows in the trip below 60 secs
tripdata_df %>% 
  filter(ride_length < 60) %>% 
  nrow()
```

## Phase 4: Analyze

### 1. Conduct descriptive analysis
Firstly, I will show the overview from the `ride_length`. The code chunks shows the mean, median, maximum and minimum number of `ride_length` in the data sets.
```{r Show the mean, median, max and min of ride_length}
# OPTION 1: Descriptive analysis on ride_length (all figures in seconds)
mean(tripdata_df$ride_length) # straight average (total ride length / rides)
median(tripdata_df$ride_length) # midpoint number in the ascending array of ride lengths
max(tripdata_df$ride_length) # longest ride
min(tripdata_df$ride_length) # shortest ride

# OPTION 2: You can condense the four lines above to one line using summary() on the specific attribute
summary(tripdata_df$ride_length)
```

The comparison between a casual rider and an annual member can be done with similar functions of `mean`, `median`, `max`, and `min`. Both casuals and members have the same minimum number (60), but the mean, median, and maximum numbers for casuals are comparatively higher than for members.
```{r show the summary of casual and member by aggregating, echo=FALSE}
tripdata_df %>%
  group_by(member_casual, day_of_week) %>%
  summarize(median_ride_length = median(ride_length))

tripdata_df %>%
  group_by(member_casual, day_of_week) %>%
  summarize(max_ride_length = max(ride_length))

tripdata_df %>%
  group_by(member_casual, day_of_week) %>%
  summarize(average_ride_length = mean(ride_length))

tripdata_df %>%
  group_by(member_casual, day_of_week) %>%
  summarize(minimum_ride_length = min(ride_length))
```

Next, I will look into the average duration and number of rides per day of the week for casual riders and annual members. This will be used for data visualization going forward.
```{r analyze trip data by type and day of week}
# analyze ridership data by type and day of week
tripdata_df %>% 
  group_by(member_casual, day_of_week) %>% 
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length))
```

### 2. Data visualization
It is important to focus on the business questions that I'll be answering, which are:

1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

With the business questions in mind, I will make sure that I don't deviate from the objectives. Therefore, my focus will be on two types of questions:

- Time vs. rider type (casual rider and annual member)
- Time vs. rideable type (classic bike, docked bike, and electric bike) vs. rider type

For each type of question, I will explore the number of rides and average duration based on weekday and month.

#### Time vs. rider type
In this section, I would like to know if there is any difference in the day of the week in terms of the number of rides and average duration.

**Bar Chart: The number of rides based on the day of the week**
```{r Bar Chart: The number of rides in week of day}
tripdata_df %>%
  mutate(weekday = lubridate::wday(started_at, label = TRUE)) %>%
  group_by(member_casual, weekday) %>%
  summarise(number_of_rides = n(), average_duration = mean(ride_length)) %>%
  arrange(member_casual, weekday) %>%
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")

```

**Bar Chart: The average duration based on the day of the week**
```{r Bar Chart: The average duration in week of day}
tripdata_df %>% 
  mutate(weekday = lubridate::wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")
```

I'll look at the next chart in a month to see whether they vary in number of rides and average duration within a year.
**Line Chart: The number of rides by rider type in months**
```{r Line Chart: The number of rides by rider type in months}
tripdata_df %>% 
  mutate(month = month(started_at)) %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  geom_point() +
  geom_line(aes(color = member_casual)) +
  scale_x_continuous(breaks = seq(1, 12, by = 1))
```

**Line Chart: The average duration by rider type in months**
```{r Line Chart: The average duration by rider type in months}
tripdata_df %>% 
  mutate(month = month(started_at)) %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = average_duration, fill = member_casual)) +
  geom_point() +
  geom_line(aes(color = member_casual)) +
  scale_x_continuous(breaks = seq(1, 12, by = 1))
```

#### Time vs. rideable type vs. rider type
The previous section only looked into two variables, which are time vs. rider type. However, this section will include one more: rideable types (classic bikes, docked bikes, and electric bikes). I am using the `facet_grid()`[^2] function to separate rideables into each chart. Each rideable type shows the number of rides and average duration of rides based on the day of the week and month.

[^2]: The `facet_grid` technique used was inspired by [Matt Herman](https://mattherman.info/blog/fix-facet-width/): *SPACE = "FREE" OR HOW TO FIX YOUR FACET (WIDTH)*

**Bar chart: the number of rides vs. weekday vs. rider type**
```{r Bar chart: the number of rides vs. weekday vs. rider type}
tripdata_df %>% 
  mutate(weekday = lubridate::wday(started_at, label = TRUE)) %>% 
  group_by(rideable_type, weekday, member_casual) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  coord_flip() +
  facet_grid(rows = vars(rideable_type), scales = "free_y", switch = "y", space = "free_y") 
  
```

**Bar chart: the average duration vs. weekday vs. rider type**
```{r Bar chart: the average duration vs. weekday vs. rider type}
tripdata_df %>% 
  mutate(weekday = lubridate::wday(started_at, label = TRUE)) %>% 
  group_by(rideable_type, weekday, member_casual) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  coord_flip() +
  facet_grid(rows = vars(rideable_type), scales = "free_y", switch = "y", space = "free_y") 
```

**Line chart: the number of rides vs. weekday vs. rider type**
```{r Line chart: the number of rides vs. weekday vs. rider type}
tripdata_df %>% 
  filter(member_casual == "casual") %>% 
  mutate(month = month(started_at)) %>% 
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = rideable_type)) +
  geom_point() +
  geom_line(aes(color = rideable_type), linewidth=0.75) +
  scale_x_continuous(breaks = seq(1, 12, by = 1)) +
  scale_colour_manual(values = c("#353436", "#D55E00", "#02e302"), 
                    breaks = c("classic_bike", "docked_bike", "electric_bike"))

tripdata_df %>% 
  filter(member_casual == "member") %>% 
  mutate(month = month(started_at)) %>% 
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = rideable_type)) +
  geom_point() +
  geom_line(aes(color = rideable_type), linewidth=0.75) +
  scale_x_continuous(breaks = seq(1, 12, by = 1)) +
  scale_colour_manual(values = c("#353436", "#D55E00", "#02e302"), 
                    breaks = c("classic_bike", "docked_bike", "electric_bike"))
```
It is apparent that in chart, Bar chart: the average duration vs. weekday vs. rider type, the average duration of docked bikes is significantly higher than the other two bikes (classic bikes and electric bikes), despite having the lowest number of rides. Another note is that docked bikes are only being used by casuals.

Having docked bikes would make the other two bikes harder to compare. Therefore, I will not include docked bikes on the next chart, where I will be looking in months to see whether they vary in average duration within a year based on rideables.

**Line chart: the average duration vs. weekday vs. rider type**
```{r Line chart: the average duration vs. weekday vs. rider type}
tripdata_df %>% 
  filter(member_casual == "casual" & (rideable_type == "classic_bike" | rideable_type == "electric_bike")) %>% 
  mutate(month = month(started_at)) %>% 
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, month)  %>% 
  ggplot(aes(x = month, y = average_duration, fill = rideable_type)) +
  geom_point() +
  geom_line(aes(color = rideable_type), size=0.75) +
  scale_x_continuous(breaks = seq(1, 12, by = 1)) +
  scale_colour_manual(values = c("#353436", "#02e302"), 
                    breaks = c("classic_bike", "electric_bike"))

tripdata_df %>% 
  filter(member_casual == "member") %>% 
  mutate(month = month(started_at)) %>% 
  group_by(rideable_type, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length), .groups = "drop") %>% 
  arrange(rideable_type, month)  %>% 
  ggplot(aes(x = month, y = average_duration, fill = rideable_type)) +
  geom_point() +
  geom_line(aes(color = rideable_type), size=0.75) +
  scale_x_continuous(breaks = seq(1, 12, by = 1)) +
  scale_colour_manual(values = c("#353436", "#02e302"), 
                    breaks = c("classic_bike", "electric_bike"))
```

## Phase 5: Share 
This phase will involve performing my analysis, gaining some insights into my data, and creating visualisations to share my findings. The visualisation, however, should be sophisticated and polished to effectively communicate with the executive team.

In this phase, the steps include:

1. Sketch some ideas for how I will visualise the data.
2. Use tools to create your visualisation. Use presentation software, such as PowerPoint or Google Slides; a spreadsheet program; Tableau; or R.
3. Create data visualisation, remembering that contrast should be used to draw the audience’s attention to the most important insights. Use artistic principles, including size, colour, and shape.
4. Ensure clear meaning through the proper use of common elements, such as headlines, subtitles, and labels.
5. Refine your data visualisation by paying deep attention to detail.

## Phase 6: Act
This will be the last part of the data analysis process. This is where I will prepare the deliverables Morena asked me to create, including the three top recommendations based on your analysis.

## Future Considerations
As I mentioned before, this case study did not include all of the factors that could affect bike ridership, such as weather. However, the data sets could be used to conduct a more comprehensive study of ride patterns, such as the distance ridden and the geographical pattern of stations. This could provide valuable insights into whether distance and certain areas affect the number of people who become members. Due to time constraints, I was unable to investigate these factors further.
