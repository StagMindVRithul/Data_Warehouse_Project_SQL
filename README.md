# Modern Data Warehouse and Analytics Project

Welcome to the **Data Warehouse Project** repository! 🚀  
This project showcases a **modern data warehouse** built using **SQL Server**, covering **ETL (Extract, Transform, Load), Data Modeling, and Analytics**. Designed as a portfolio project, it follows industry best practices in data engineering and analytics.

---
## 🏗️ Data Architecture

This project implements the **Medallion Architecture** with three structured layers:

1. **Bronze Layer**: Stores raw data ingested from multiple sources (CSV files, APIs, databases) into SQL Server.
2. **Silver Layer**: Processes and cleanses data, ensuring consistency and quality before transformation.
3. **Gold Layer**: Optimized for analytics, structured in a **Star Schema** for efficient querying and reporting.

![Data Architecture](docs/data_architecture.png)

---

## Prerequisites for Setting Up SQL Server on Docker (Mac Users)

### 1. Install Docker
Ensure you have Docker installed on your Mac. If not, download and install it from [Docker's official website](https://www.docker.com/products/docker-desktop/).

### 2. Run SQL Server in Docker
Open your terminal and run the following command to start an Azure SQL Edge container:

```sh
docker run -e "ACCEPT_EULA=1" \
    -e "MSSQL_SA_PASSWORD=MyStrongPass123" \
    -e "MSSQL_PID=Developer" \
    -e "MSSQL_USER=SA" \
    -p 1433:1433 -d --name=sql \
    mcr.microsoft.com/azure-sql-edge
```

- This will create and start a SQL Server instance in a Docker container.
- The **password** is set as `MyStrongPass123`. You can modify it in the command if needed.

### 3. Install Azure Data Studio
Download and install **Azure Data Studio** from [Microsoft's official website](https://learn.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver16).

### 4. Connect to SQL Server in Azure Data Studio
1. Open **Azure Data Studio**.
2. Click on **New Connection**.
3. Use the following credentials:
   - **Server Name:** `localhost`
   - **Authentication:** SQL Login
   - **Username:** `SA`
   - **Password:** `MyStrongPass123` (or the one you set in the Docker command)
   - **Encrypt:** `Mandatory`
   - **Trust server certificate:** `True`
   - Click on `Remember password`.
4. Finally click **Connect**.

### 5. Move Files to Docker Container (For BULK INSERT Operations)
When using a **Docker-based SQL Server**, you **cannot** directly BULK INSERT from your local machine. You need to move files into the Docker container's data folder first.

#### Steps to Move Files:

1. **Check Active Containers**
   ```sh
   docker ps
   ```
   - Note the **container name** from the output.

2. **Copy Files from Mac to Docker Container**
   ```sh
   docker cp 'file_path_in_mac' 'container_name':/var/opt/mssql/data/'file_name'
   ```
   - Replace `'file_path_in_mac'` with the full path of your local file.
   - Replace `'container_name'` with your actual container name (e.g., `sql`).
   - Replace `'file_name'` with the actual name of your data file.

3. **Access the Docker Container**
   ```sh
   docker exec -it 'container_name' bash
   ```

4. **Verify Files in the Data Folder**
   ```sh
   ls -l /var/opt/mssql/data
   ```

Repeat these steps until all required files are moved to the Docker container.

### 6. Next Steps
Once everything is set up, you can start running queries and managing your database in Azure Data Studio. 🎯

Feel free to modify the password in the Docker command and Azure Data Studio settings if needed!

---

## 📖 Project Overview

This project involves:

1. **ETL Pipelines**: Automating data ingestion, transformation, and loading into SQL Server.
2. **Data Modeling**: Designing **fact and dimension tables** to support analytical queries.
3. **Analytics & Reporting**: Generating SQL-based insights and dashboards.

🎯 Ideal for professionals and students in:
- **Data Engineering**
- **SQL Development**
- **ETL Pipeline Development**
- **Data Analytics**

---
## 🛠️ Tech Stack & Tools

✅ **Azure Data Studio** – Core database for warehousing  

✅ **Azure SQL Edge** – ETL pipeline development   

✅ **Draw.io** – Data architecture and modeling diagrams

✅ **Notion** – Project Management & Task Tracking

✅ **Docker** – Containerizing and running SQL Server

---
## 🚀 Project Workflow

### **1️⃣ Data Engineering (ETL Process)**
- Extracting raw data from multiple sources.
- Transforming and cleansing data to maintain integrity.
- Loading structured data into **SQL Server**.

### **2️⃣ Data Modeling**
- Implementing **Star Schema** for analytical efficiency.
- Designing optimized fact and dimension tables.

### **3️⃣ Analytics & Reporting**
- Writing advanced **SQL queries** for data analysis.
- Building dashboards in **Power BI/Tableau**.

---
## 📂 Repository Structure

```
data-warehouse-project/
│
├── datasets/                           # Raw data files (ERP & CRM sources)
│
├── docs/                               # Documentation & architecture diagrams
│   ├── etl.drawio                      # ETL pipeline architecture
│   ├── data_architecture.drawio        # Warehouse architecture diagram
│   ├── data_models.drawio              # Star schema design
│   ├── naming-conventions.md           # Standard naming conventions
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Raw data ingestion scripts
│   ├── silver/                         # Data cleansing and transformation scripts
│   ├── gold/                           # Analytical model scripts
│
├── tests/                              # Data validation & quality checks
│
├── README.md                           # Project documentation
├── LICENSE                             # Project license
├── .gitignore                          # Git ignored files
└── requirements.txt                    # Dependencies & setup requirements
```

---
## 📊 Business Use Cases

This data warehouse supports analytical insights such as:
- **Customer Segmentation** – Identify key customer demographics.
- **Sales Performance Analysis** – Evaluate trends and revenue growth.
- **Inventory Management** – Optimize stock levels based on demand.

---
## 🔧 Installation & Setup

1️⃣ **Clone the repository:**  
```bash
   git clone https://github.com/StagMindVRithul/Data_Warehouse_Project_SQL.git
```

2️⃣ **Set up SQL Server and import datasets.**

3️⃣ **Run ETL scripts** to load and transform data.

4️⃣ **Use Power BI/Tableau** to build interactive dashboards.

---
## 🔥 Future Enhancements

🔹 Migrate to **Azure Synapse Analytics** for cloud scalability.  
🔹 Automate ETL pipelines using **Apache Airflow**.  
🔹 Optimize performance with **columnstore indexes**.  

---
## 🛡️ License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and share with attribution.

---
## 📢 Connect with Me

Let's collaborate! Connect with me on:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/v-rithul-06b5632b6/)  

🚀 **Happy Coding!**
