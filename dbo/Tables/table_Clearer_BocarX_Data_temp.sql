CREATE TABLE [dbo].[table_Clearer_BocarX_Data_temp] (
    [report_name]            TEXT            NULL,
    [report_day]             DATETIME2 (7)   NULL,
    [account_name]           TEXT            NULL,
    [CCY]                    TEXT            NULL,
    [trade_date]             DATETIME2 (7)   NULL,
    [deal_number]            NUMERIC (28, 6) NULL,
    [product_name]           TEXT            NULL,
    [contract_start_date]    DATETIME2 (7)   NULL,
    [contract_end_date]      DATETIME2 (7)   NULL,
    [projection_index1]      TEXT            NULL,
    [external_business_unit] TEXT            NULL,
    [internal_portfolio]     TEXT            NULL,
    [toolset]                TEXT            NULL,
    [contract_size]          NUMERIC (28, 6) NULL,
    [position]               NUMERIC (28, 6) NULL,
    [trade_price]            NUMERIC (28, 6) NULL,
    [callput]                TEXT            NULL,
    [strike_price]           NUMERIC (28, 6) NULL,
    [premium]                NUMERIC (28, 6) NULL,
    [broker]                 TEXT            NULL,
    [total_fee_rate]         NUMERIC (28, 6) NULL,
    [total_fee]              NUMERIC (28, 6) NULL,
    [clearer_ID]             INT             NULL
);


GO

