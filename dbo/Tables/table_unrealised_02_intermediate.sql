CREATE TABLE [dbo].[table_unrealised_02_intermediate] (
    [ID]                                         INT            IDENTITY (1, 1) NOT NULL,
    [COB]                                        DATE           NULL,
    [Deal_Number]                                VARCHAR (20)   NULL,
    [Trade_Date]                                 DATE           NULL,
    [Term_Start]                                 DATE           NULL,
    [Term_End]                                   DATE           NULL,
    [Internal_Legal_Entity]                      VARCHAR (100)  NULL,
    [Desk_Name]                                  VARCHAR (100)  NULL,
    [Desk_ID]                                    VARCHAR (100)  NULL,
    [Desk_CCY]                                   VARCHAR (3)    NULL,
    [SubDesk]                                    VARCHAR (100)  NULL,
    [RevRec_SubDesk]                             VARCHAR (100)  NULL,
    [Book_Name]                                  VARCHAR (100)  NULL,
    [Book_ID]                                    VARCHAR (100)  NULL,
    [Internal_Portfolio]                         VARCHAR (100)  NULL,
    [Portfolio_ID]                               VARCHAR (100)  NULL,
    [Instrument_Type]                            VARCHAR (100)  NULL,
    [Unit_of_Measure]                            VARCHAR (100)  NULL,
    [External_Legal_Entity]                      VARCHAR (100)  NULL,
    [External_Business_Unit]                     VARCHAR (100)  NULL,
    [External_Portfolio]                         VARCHAR (100)  NULL,
    [Projection_Index_Name]                      VARCHAR (100)  NULL,
    [Projection_Index_Group]                     VARCHAR (100)  NULL,
    [Product_Name]                               VARCHAR (100)  NULL,
    [Adjustment_ID]                              VARCHAR (200)  NULL,
    [Cashflow_Payment_Date]                      DATE           NULL,
    [LegEndDate]                                 DATE           NULL,
    [Delivery_Date]                              DATE           NULL,
    [Delivery_Month]                             DATE           NULL,
    [Trade_Price]                                FLOAT (53)     NULL,
    [Cashflow_Type]                              VARCHAR (100)  NULL,
    [Cashflow_Type_ID]                           INT            NULL,
    [Contract_Name]                              VARCHAR (100)  NULL,
    [Unit_Of_Account]                            VARCHAR (20)   NULL,
    [ShortTerm_LongTerm]                         VARCHAR (2)    NULL,
    [Accounting_Delivery_Month]                  DATE           NULL,
    [Counterparty_Group]                         VARCHAR (100)  NULL,
    [Order_Number]                               VARCHAR (50)   NULL,
    [Partner_Code]                               INT            NULL,
    [Active_Period]                              INT            NULL,
    [Buy_Sell]                                   VARCHAR (5)    NULL,
    [Orig_Month]                                 DATE           NULL,
    [Target_Month]                               DATE           NULL,
    [Accounting_Treatment]                       VARCHAR (200)  NULL,
    [Volume]                                     FLOAT (53)     NULL,
    [Volume_Avaliable]                           FLOAT (53)     NULL,
    [Volume_Used]                                FLOAT (53)     NULL,
    [Hedge_ID]                                   VARCHAR (50)   NULL,
    [Hedge_Quote]                                FLOAT (53)     NULL,
    [Product_ticker]                             VARCHAR (200)  NULL,
    [RACE_Position]                              INT            NULL,
    [Commodity_Type]                             VARCHAR (50)   NULL,
    [Balance_Sheet_Account]                      VARCHAR (100)  NULL,
    [PNL_OCI_Account]                            VARCHAR (100)  NULL,
    [Cashflow_CCY]                               VARCHAR (10)   NULL,
    [BU_CCY]                                     VARCHAR (10)   NULL,
    [Accounting_Comment]                         VARCHAR (2000) NULL,
    [Adjustment_Comment]                         VARCHAR (2000) NULL,
    [Adjustment_Category]                        VARCHAR (200)  NULL,
    [Unrealised_Discounted_BU_CCY]               FLOAT (53)     NULL,
    [Realised_Discounted_BU_CCY]                 FLOAT (53)     NULL,
    [Unrealised_Discounted_CF_CCY]               FLOAT (53)     NULL,
    [Realised_Discounted_CF_CCY]                 FLOAT (53)     NULL,
    [Total_Discounted_BU_CCY]                    FLOAT (53)     NULL,
    [Total_Accounting_Discounted_BU_CCY]         FLOAT (53)     NULL,
    [Total_Discounted_CF_CCY]                    FLOAT (53)     NULL,
    [Total_Accounting_Discounted_CF_CCY]         FLOAT (53)     NULL,
    [Total_Accounting_Discounted_CF_CCY_SAP_EUR] FLOAT (53)     NULL,
    [FX_Rate_CF_CCY_EUR]                         FLOAT (53)     NULL,
    [FileID]                                     INT            NULL,
    [DataSource]                                 VARCHAR (30)   NULL,
    [UserName]                                   VARCHAR (30)   CONSTRAINT [DF_Table_Unrealised_02_intermediate_UserName] DEFAULT (user_name()) NULL,
    [Last_Update]                                DATETIME       CONSTRAINT [DF_Table_Unrealised_02_intermediate_Last_Update] DEFAULT (getdate()) NULL,
    CONSTRAINT [pk_unrealised_02_intermediate] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

