-- =============================================
-- Author:		<Arnao | jarnao@msn.com>
-- Create date: <2013-01-14>
-- Description:	<Generar números aleatorios en SQL Server, PIN (Personal Identification Number)
--               Los números generados tienen una longitud de diez dígitos.>
-- =============================================

/* INICIO */
SET NOCOUNT ON;
DECLARE @cardcount INT;
SET @cardcount = 10;

DECLARE @Subscriber TABLE (PIN VARCHAR(20));
DECLARE @i INT, @j INT, @pins VARCHAR(20), @pinimpar VARCHAR(20), @pinpar VARCHAR(20);
SET @i = 0;
SET @j = 0;
SET @pinpar = '';
SET @pinimpar = '';
SET @pins = '';

WHILE (@i < @cardcount)
	BEGIN        
        IF ROUND (@j/2,0) < ROUND((@j+1)/2,0)
            BEGIN
                SET @pins = (SELECT CONVERT(VARCHAR(10),CONVERT(VARCHAR(4),CONVERT(INT, RAND( (DATEPART(mi, GETDATE()) * 100000 )
							+ (DATEPART(ss, GETDATE()) * 1000 )
							+ DATEPART(ms, GETDATE()) ) * 100000) % 10000)+CONVERT(VARCHAR(6),CONVERT(INT, RAND( (DATEPART(mi, GETDATE()) * 10000000 )
							+ (DATEPART(ss, GETDATE()) * 100000 ) + (DATEPART(wk, GETDATE()) * 100000 )
							+ DATEPART(ms, GETDATE()) ) * 10000000) % 1000000)));
                SET @pins = REPLICATE('0', 10 - LEN(@pins)) + @pins;
                SET @pinimpar = @pins;
                SET @j = @j + 1;
            END
        ELSE
            BEGIN
                SET @pins = (SELECT CONVERT(VARCHAR(10),CONVERT(VARCHAR(6),CONVERT(INT, RAND( (DATEPART(mm, GETDATE()) * 10000000 ) + (DATEPART(ss, GETDATE()) * 100000 )
							+ DATEPART(ms, GETDATE()) ) * 10000000) % 1000000))
							+ CONVERT(VARCHAR(4),CONVERT(INT, RAND( (DATEPART(mi, GETDATE()) * 100000 )
							+ (DATEPART(wk, GETDATE()) * 100000 ) + (DATEPART(ss, GETDATE()) * 1000 ) + DATEPART(ms, GETDATE()) ) * 100000) % 10000));
                SET @pins = @pins + REPLICATE('0', 10 - LEN(@pins));
                SET @pinpar = @pins;
                SET @j = @j + 1;
            END
            
		WAITFOR DELAY '00:00:00.001';

		IF @pins = RIGHT(@pinimpar,LEN(@pins))
			BEGIN
				WAITFOR DELAY '00:00:00.002';
                SET @pins = (SELECT CONVERT(VARCHAR(10),CONVERT(VARCHAR(4),CONVERT(INT, RAND( (DATEPART(ss, GETDATE()) * 100000 )
					        + (DATEPART(ss, GETDATE()) * 1000 ) + (DATEPART(mi, GETDATE()) * 100000 )
						    + DATEPART(ms, GETDATE()) ) * 100000) % 10000)+CONVERT(VARCHAR(6),CONVERT(INT, RAND( (DATEPART(mi, GETDATE()) * 10000000 )
							+ (DATEPART(ss, GETDATE()) * 100000 ) + (DATEPART(wk, GETDATE()) * 100000 )
							+ DATEPART(ms, GETDATE()) ) * 10000000) % 1000000)));
			END
        ELSE
			IF @pins = LEFT(@pinpar,LEN(@pins))
				BEGIN
					WAITFOR DELAY '00:00:00.003';
					SET @pins = (SELECT CONVERT(VARCHAR(10),CONVERT(VARCHAR(4),CONVERT(INT, RAND( (DATEPART(ss, GETDATE()) * 100000 )
								+ (DATEPART(ss, GETDATE()) * 1000 ) + (DATEPART(mi, GETDATE()) * 100000 ) + (DATEPART(mi, GETDATE()) * 1000 )
								+ DATEPART(ms, GETDATE()) ) * 100000) % 10000)+CONVERT(VARCHAR(6),CONVERT(INT, RAND( (DATEPART(mi, GETDATE()) * 10000000 )
								+ (DATEPART(ss, GETDATE()) * 100000 ) + (DATEPART(wk, GETDATE()) * 100000 )
								+ DATEPART(ms, GETDATE()) ) * 10000000) % 1000000)));
				END

			IF LEN(@pins) < 10
				BEGIN
					IF CONVERT(INT, RAND()*1000) % 2 = 1
						BEGIN
							SET @pins = REPLICATE('0', 10 - LEN(@pins)) + @pins;
						END
					ELSE 
						BEGIN
							SET @pins = @pins + REPLICATE('0', 10 - LEN(@pins));
						END
				END

			-- INSERT to DB
			IF (SELECT COUNT (*) FROM @Subscriber WHERE Pin = @pins) = 0
				BEGIN
					INSERT INTO @Subscriber (PIN) VALUES (@pins);
					SET @i = @i + 1;
			END
	END
/* FINAL */

--RESULTADO
SELECT pin, len(pin) as longitud
FROM @Subscriber;
