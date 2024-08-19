CREATE ROLE [FinReconUsers]
    AUTHORIZATION [dbo];


GO

ALTER ROLE [FinReconUsers] ADD MEMBER [m.beckmann];


GO

ALTER ROLE [FinReconUsers] ADD MEMBER [ENERGY\FNC_RWEST_FIN_USERS];


GO

ALTER ROLE [FinReconUsers] ADD MEMBER [GROUP\FNC_RWEST_FIN_USERS];


GO

ALTER ROLE [FinReconUsers] ADD MEMBER [testuserbulkinsert];


GO

