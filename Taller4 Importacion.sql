
USE DivisionPolitica
GO

IF OBJECT_ID('tempdb..#Japon') IS NOT NULL
    DROP TABLE #Japon

CREATE TABLE #Japon(
    Prefectura varchar(50) NOT NULL,
    Capital varchar(50) NOT NULL,
    Area float NULL,
    Poblacion int NULL
)

BULK INSERT #Japon
    FROM 'C:\BD\Japon.csv'
    WITH (
        DATAFILETYPE = 'char',
        FIELDTERMINATOR = ','
    )

INSERT INTO Continente(Nombre)
    SELECT 'Asia'
        WHERE NOT EXISTS(
            SELECT 1
                FROM Continente
                WHERE Nombre = 'Asia'
        )

INSERT INTO TipoRegion(TipoRegion)
    SELECT 'Prefectura'
        WHERE NOT EXISTS(
            SELECT 1
                FROM TipoRegion
                WHERE TipoRegion = 'Prefectura'
        )

INSERT INTO Pais(Nombre, IdContinente, IdTipoRegion)
    SELECT 'Japón', C.Id, TR.Id
        FROM Continente C
            CROSS JOIN TipoRegion TR
        WHERE C.Nombre = 'Asia'
            AND TR.TipoRegion = 'Prefectura'
            AND NOT EXISTS(
                SELECT 1
                    FROM Pais
                    WHERE Nombre = 'Japón'
            )

INSERT INTO Region(Nombre, IdPais, Area, Poblacion)
    SELECT J.Prefectura, P.Id, J.Area, J.Poblacion
        FROM #Japon J
            JOIN Pais P ON P.Nombre = 'Japón'
        WHERE NOT EXISTS(
            SELECT 1
                FROM Region R
                WHERE R.Nombre = J.Prefectura
                    AND R.IdPais = P.Id
        )

INSERT INTO Ciudad(Nombre, IdRegion, CapitalRegion)
    SELECT J.Capital, R.Id, 1
        FROM #Japon J
            JOIN Pais P ON P.Nombre = 'Japón'
            JOIN Region R ON R.Nombre = J.Prefectura
                AND R.IdPais = P.Id
        WHERE NOT EXISTS(
            SELECT 1
                FROM Ciudad C
                WHERE C.Nombre = J.Capital
                    AND C.IdRegion = R.Id
        )

SELECT *
    FROM Pais P
        JOIN Region R ON P.Id = R.IdPais
        JOIN Ciudad C ON R.Id = C.IdRegion
    WHERE P.Nombre = 'Japón'
GO


CREATE TABLE Moneda(
    Id int IDENTITY NOT NULL,
    CONSTRAINT pkMoneda_Id PRIMARY KEY (Id),
    Moneda varchar(100) NOT NULL,
    Sigla varchar(5) NULL,
    Imagen varbinary(max) NULL
)
GO

CREATE UNIQUE INDEX ixMoneda
    ON Moneda(Moneda)
GO

ALTER TABLE Pais
    ADD IdMoneda int NULL,
        Mapa varbinary(max) NULL,
        Bandera varbinary(max) NULL
GO

INSERT INTO Moneda(Moneda)
    SELECT DISTINCT LTRIM(RTRIM(P.Moneda))
        FROM Pais P
        WHERE P.Moneda IS NOT NULL
            AND LTRIM(RTRIM(P.Moneda)) <> ''
            AND NOT EXISTS(
                SELECT 1
                    FROM Moneda M
                    WHERE M.Moneda = LTRIM(RTRIM(P.Moneda))
            )
GO


UPDATE P
    SET P.IdMoneda = M.Id
    FROM Pais P
        JOIN Moneda M ON M.Moneda = LTRIM(RTRIM(P.Moneda))
GO

ALTER TABLE Pais
    ADD CONSTRAINT fkPais_IdMoneda FOREIGN KEY (IdMoneda)
        REFERENCES Moneda(Id)
GO

ALTER TABLE Pais
    DROP COLUMN Moneda
GO

SELECT P.Id, P.Nombre, M.Moneda, P.Mapa, P.Bandera
    FROM Pais P
        LEFT JOIN Moneda M ON M.Id = P.IdMoneda
GO