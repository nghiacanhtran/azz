USE [master]
GO
/****** Object:  Database [web365]    Script Date: 27/08/2015 6:34:54 CH ******/
CREATE DATABASE [web365] ON  PRIMARY 
( NAME = N'web365', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\web365.mdf' , SIZE = 4288KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'web365_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\web365_log.ldf' , SIZE = 1072KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [web365].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [web365] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [web365] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [web365] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [web365] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [web365] SET ARITHABORT OFF 
GO
ALTER DATABASE [web365] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [web365] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [web365] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [web365] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [web365] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [web365] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [web365] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [web365] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [web365] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [web365] SET  ENABLE_BROKER 
GO
ALTER DATABASE [web365] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [web365] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [web365] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [web365] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [web365] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [web365] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [web365] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [web365] SET RECOVERY FULL 
GO
ALTER DATABASE [web365] SET  MULTI_USER 
GO
ALTER DATABASE [web365] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [web365] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'web365', N'ON'
GO
USE [web365]
GO
/****** Object:  UserDefinedFunction [dbo].[ConvertToAscii]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ConvertToAscii](@inputVar NVARCHAR(MAX) )
RETURNS NVARCHAR(MAX)
AS
BEGIN    
    IF (@inputVar IS NULL OR @inputVar = '')  RETURN ''
	
	SET @inputVar = LOWER(@inputVar)

    DECLARE @RT NVARCHAR(MAX)
    DECLARE @SIGN_CHARS NCHAR(256)
    DECLARE @UNSIGN_CHARS NCHAR (256)

    SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' + NCHAR(272) + NCHAR(208)
    SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'

    DECLARE @COUNTER int
    DECLARE @COUNTER1 int
   
    SET @COUNTER = 1
    WHILE (@COUNTER <= LEN(@inputVar))
    BEGIN  
        SET @COUNTER1 = 1
        WHILE (@COUNTER1 <= LEN(@SIGN_CHARS) + 1)
        BEGIN
            IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@inputVar,@COUNTER ,1))
            BEGIN          
                IF @COUNTER = 1
                    SET @inputVar = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)-1)      
                ELSE
                    SET @inputVar = SUBSTRING(@inputVar, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)- @COUNTER)
                BREAK
            END
            SET @COUNTER1 = @COUNTER1 +1
        END
        SET @COUNTER = @COUNTER +1
    END
	WHILE PATINDEX( '%[",~,@,/,.,:,?,#,$,%,&,*,(,)]%', @inputVar ) > 0
          SET @inputVar = Replace(REPLACE( @inputVar, SUBSTRING( @inputVar, PATINDEX( '%[",~,@,/,.,:,?,#,$,%,&,*,(,)]%', @inputVar ), 1 ),''),'-',' ')
    SET @inputVar = replace(@inputVar,' ','-')
	--PRINT @inputVar
    RETURN @inputVar
END























GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString] 
( 
	@stringToSplit NVARCHAR(MAX),
	@key NVARCHAR(255)
)
RETURNS
 @returnList TABLE ([Name] [nvarchar] (500))
AS
BEGIN

	DECLARE @name NVARCHAR(255)
	DECLARE @pos INT

	WHILE CHARINDEX(@key, @stringToSplit) > 0
	BEGIN
		SELECT @pos  = CHARINDEX(@key, @stringToSplit)  
		SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

		INSERT INTO @returnList 
		SELECT @name

		SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
	END

	INSERT INTO @returnList
	SELECT @stringToSplit

	RETURN
END



GO
/****** Object:  UserDefinedFunction [dbo].[SplitStringWithOrder]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitStringWithOrder] 
(
    @string NVARCHAR(MAX),
    @delimiter CHAR(1)
)
RETURNS @output TABLE(
    Value NVARCHAR(MAX),
	DisplayOrder int
)
BEGIN
    DECLARE @start INT, @end INT, @count INT = 1
    SELECT @start = 1, @end = CHARINDEX(@delimiter, @string)


    WHILE @start < LEN(@string) + 1 BEGIN
        IF @end = 0 
            SET @end = LEN(@string) + 1

        INSERT INTO @output (Value, DisplayOrder) 
        VALUES(SUBSTRING(@string, @start, @end - @start), @count)
		SET @count = @count + 1
        SET @start = @end + 1
        SET @end = CHARINDEX(@delimiter, @string, @start)
    END
    RETURN
END



GO
/****** Object:  Table [dbo].[tblAdverties_Picture_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdverties_Picture_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AdvertiesID] [int] NULL,
	[PictureID] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_tblAdverties_Picture] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblAdvertise]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdvertise](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Detail] [nvarchar](1000) NULL,
	[Link] [nvarchar](1000) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[LanguageId] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblAdvertise] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblArticle]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblArticle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NULL,
	[TitleAscii] [nvarchar](255) NULL,
	[TypeID] [int] NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [ntext] NULL,
	[Viewed] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblNews] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblArticle_Picture_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblArticle_Picture_Map](
	[ArticleID] [int] NOT NULL,
	[PictureID] [int] NOT NULL,
 CONSTRAINT [PK_tblArticle_Picture_Map] PRIMARY KEY CLUSTERED 
(
	[ArticleID] ASC,
	[PictureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblComment]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[AccountID] [int] NULL,
	[Detail] [ntext] NULL,
	[Status] [bit] NULL,
	[AdminId] [int] NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [PK_tblComment] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblContact]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblContact](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Gender] [bit] NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[Message] [nvarchar](4000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsViewed] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblContact] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblCustomer]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCustomer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](255) NULL,
	[Password] [nvarchar](255) NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Gender] [bit] NULL,
	[BirthDay] [datetime] NULL,
	[PictureID] [int] NULL,
	[Token] [nvarchar](255) NULL,
	[DateExpiredToken] [datetime] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblAccount] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDetail]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NULL,
	[Number] [int] NULL,
 CONSTRAINT [PK_tblProductDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDistributor]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDistributor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblManuFactory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDomain]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDomain](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Domain] [nvarchar](50) NULL,
	[TypeProductID] [int] NULL,
	[FileCss] [nvarchar](50) NULL,
 CONSTRAINT [PK_tblDomain] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblFile]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[FileName] [nvarchar](255) NULL,
	[Size] [bigint] NULL,
	[Number] [int] NULL,
	[TypeID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](1000) NULL,
	[PictureID] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblFileUpload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblGroup_Article_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGroup_Article_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[NewsID] [int] NULL,
	[GroupID] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_tblGroup_News_Map_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblGroup_TypeArticle_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGroup_TypeArticle_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ArticleTypeID] [int] NULL,
	[GroupTypeID] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_tblGroup_TypeArticle_Map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblGroupArticle]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGroupArticle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblGroupNews] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblGroupTypeArticle]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblGroupTypeArticle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblLanguage]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLanguage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Code] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblLanguage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblLayoutContent]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLayoutContent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[LanguageId] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblLayoutContent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblManufacturer]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblManufacturer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblManufacturer] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMenu]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMenu](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Link] [nvarchar](255) NULL,
	[Target] [nvarchar](255) NULL,
	[CssClass] [nvarchar](255) NULL,
	[DisplayOrder] [int] NULL,
	[LanguageId] [int] NULL,
	[Parent] [int] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NOT NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblMenu] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblOrder]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrder](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderStatusID] [int] NULL,
	[TotalCost] [money] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[Note] [nvarchar](1000) NULL,
	[CustomerName] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[CustomerID] [int] NULL,
	[IsViewed] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblOrder] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblOrder_Shipping]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrder_Shipping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[CustomerName] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
 CONSTRAINT [PK_tblOrder_Shipping] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblOrder_Status]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrder_Status](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
 CONSTRAINT [PK_tblOrder_Status] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblOrderDetail]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblOrderDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[ProductVariantID] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 0) NULL,
	[OrderID] [int] NULL,
 CONSTRAINT [PK_tblOrderDetail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPage]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPage](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Link] [nvarchar](255) NULL,
	[ClassAtrtibute] [nvarchar](255) NULL,
	[Parent] [int] NULL,
	[HasChild] [bit] NULL,
	[Number] [int] NULL,
	[Detail] [nvarchar](4000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblPage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPage_Role]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPage_Role](
	[RoleId] [int] NOT NULL,
	[PageId] [int] NOT NULL,
 CONSTRAINT [PK_tblPage_Role] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[PageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPicture]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPicture](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[FileName] [nvarchar](255) NULL,
	[TypeID] [int] NULL,
	[Summary] [nvarchar](255) NULL,
	[Alt] [nvarchar](255) NULL,
	[Link] [nvarchar](255) NULL,
	[Size] [bigint] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblImage_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Serial] [nvarchar](255) NULL,
	[TypeID] [int] NULL,
	[Manufacturer] [int] NULL,
	[Distributor] [int] NULL,
	[Price] [decimal](18, 0) NULL,
	[Quantity] [int] NULL,
	[PictureID] [int] NULL,
	[HighLights] [nvarchar](4000) NULL,
	[Summary] [nvarchar](4000) NULL,
	[Detail] [ntext] NULL,
	[Number] [int] NULL,
	[Viewed] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Attribute_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Attribute_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[ProductID] [int] NULL,
	[AttributeID] [int] NULL,
 CONSTRAINT [PK_tblProduct_Attribute_Map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_File_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_File_Map](
	[ProductID] [int] NOT NULL,
	[FileID] [int] NOT NULL,
 CONSTRAINT [PK_tblProduct_File_Map] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC,
	[FileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Filter_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Filter_Map](
	[ProductID] [int] NOT NULL,
	[FilterID] [int] NOT NULL,
 CONSTRAINT [PK_tblProduct_Filter_Map] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC,
	[FilterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Label_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Label_Map](
	[ProductID] [int] NOT NULL,
	[ProductLabelID] [int] NOT NULL,
 CONSTRAINT [PK_tblProduct_Label_Map] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC,
	[ProductLabelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Picture_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Picture_Map](
	[ProductID] [int] NOT NULL,
	[PictureID] [int] NOT NULL,
 CONSTRAINT [PK_tblProduct_Picture_Map] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC,
	[PictureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Status_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Status_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[ProductStatusID] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_tblProduct_Status_Map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProduct_Variant]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProduct_Variant](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[ProductID] [int] NULL,
	[Price] [decimal](18, 0) NULL,
	[VAT] [decimal](18, 0) NULL,
	[IsOutOfStock] [bit] NULL,
	[Quantity] [int] NULL,
	[DisplayOrder] [int] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProduct_Variant] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductAttribute]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductAttribute](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[GroupID] [int] NULL,
	[Detail] [nvarchar](1000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdaetdBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProductAttribute] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductFilter]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductFilter](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[Parent] [int] NULL,
	[Detail] [nvarchar](1000) NULL,
	[LanguageId] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProductFilter] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductGroupAttribute]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductGroupAttribute](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[ProductTypeID] [int] NULL,
	[Detail] [nvarchar](1000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProductGroupAttribute] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductLabel]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductLabel](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProductLabel] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductStatus]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductType_Group_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductType_Group_Map](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductTypeID] [int] NULL,
	[GroupTypeID] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_tblProductType_Group_Map] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductTypeGroup]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductTypeGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblProductTypeGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblReceiveInfo]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblReceiveInfo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[GroupID] [int] NULL,
	[DateCreated] [datetime] NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblReceiveInfo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblReceiveInfoGroup]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblReceiveInfoGroup](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Detail] [nvarchar](4000) NULL,
	[DateCreated] [datetime] NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblReceiveInfoGroup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSupport]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSupport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[TypeID] [int] NULL,
	[Number] [int] NULL,
	[Yahoo] [nvarchar](255) NULL,
	[Skype] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblSupport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeArticle]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeArticle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Parent] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[LanguageId] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblNewsType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeFile]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeFile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Parent] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[LanguageId] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblTypeFile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeLog]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](150) NULL,
	[Number] [int] NULL,
 CONSTRAINT [PK_tblLogType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypePicture]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypePicture](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[Parent] [int] NULL,
	[PictureID] [int] NULL,
	[Detail] [nvarchar](4000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblTypeImage] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeProduct]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeProduct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Detail] [ntext] NULL,
	[PictureID] [int] NULL,
	[Number] [int] NULL,
	[Parent] [int] NULL,
	[LanguageId] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblTypeProduct] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeProduct_Picture_Map]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeProduct_Picture_Map](
	[ProductTypeID] [int] NOT NULL,
	[PictureID] [int] NOT NULL,
 CONSTRAINT [PK_tblTypeProduct_Picture_Map_1] PRIMARY KEY CLUSTERED 
(
	[ProductTypeID] ASC,
	[PictureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeSupport]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeSupport](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[Detail] [nvarchar](1000) NULL,
	[LanguageId] [int] NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblTypeSupport] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblTypeVideo]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblTypeVideo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[PictureID] [int] NULL,
	[Parent] [int] NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblTypeVideo] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblVideo]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblVideo](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[NameAscii] [nvarchar](255) NULL,
	[Number] [int] NULL,
	[TypeID] [int] NULL,
	[Link] [nvarchar](1000) NULL,
	[Summary] [nvarchar](1000) NULL,
	[Detail] [nvarchar](max) NULL,
	[FileID] [int] NULL,
	[PictureID] [int] NULL,
	[SEOTitle] [nvarchar](255) NULL,
	[SEODescription] [nvarchar](255) NULL,
	[SEOKeyword] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[UpdatedBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_tblVideoUpload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](56) NOT NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[Gender] [bit] NULL,
	[Email] [nvarchar](255) NULL,
	[Phone] [nvarchar](255) NULL,
	[Address] [nvarchar](255) NULL,
	[Note] [nvarchar](1000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsActive] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK__UserProf__1788CC4C4C18ACB4] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_Membership]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_Membership](
	[UserId] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ConfirmationToken] [nvarchar](128) NULL,
	[IsConfirmed] [bit] NULL DEFAULT ((0)),
	[LastPasswordFailureDate] [datetime] NULL,
	[PasswordFailuresSinceLastSuccess] [int] NOT NULL DEFAULT ((0)),
	[Password] [nvarchar](128) NOT NULL,
	[PasswordChangedDate] [datetime] NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[PasswordVerificationToken] [nvarchar](128) NULL,
	[PasswordVerificationTokenExpirationDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_OAuthMembership]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_OAuthMembership](
	[Provider] [nvarchar](30) NOT NULL,
	[ProviderUserId] [nvarchar](100) NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Provider] ASC,
	[ProviderUserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_Roles]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](256) NOT NULL,
	[Detail] [nvarchar](4000) NULL,
	[DateCreated] [datetime] NULL,
	[DateUpdated] [datetime] NULL,
	[CreateBy] [nvarchar](255) NULL,
	[UpdateBy] [nvarchar](255) NULL,
	[IsShow] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK__webpages__8AFACE1ABC7ECF1D] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[webpages_UsersInRoles]    Script Date: 27/08/2015 6:34:54 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[webpages_UsersInRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[tblPage] ON 

INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (70, N'Dashboard', N'#/dashboard', N'icon-dashboard', NULL, NULL, 1, N'Dashboard', CAST(N'2014-09-12 23:18:15.687' AS DateTime), CAST(N'2014-09-12 23:18:15.687' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (71, N'Sản phẩm', NULL, N'icon-archive', NULL, 1, 2, N'Sản phẩm', CAST(N'2014-09-12 23:18:15.687' AS DateTime), CAST(N'2014-09-12 23:18:15.687' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (72, N'Sản phẩm', N'#/product', NULL, 71, NULL, 1, N'Sản phẩm', CAST(N'2014-09-12 23:18:15.687' AS DateTime), CAST(N'2014-09-12 23:18:15.687' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (73, N'Loại sản phẩm', N'#/product-type', NULL, 71, NULL, 2, NULL, CAST(N'2014-09-14 15:41:21.960' AS DateTime), CAST(N'2014-09-14 15:41:21.960' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (74, N'Nhà sản xuất', N'#/product-manufacturer', NULL, 71, NULL, 3, N'Nhà sản xuất', CAST(N'2014-09-14 15:41:59.260' AS DateTime), CAST(N'2014-09-14 15:41:59.260' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (75, N'Nhà phân phối', N'#/product-distributor', NULL, 71, NULL, 4, NULL, CAST(N'2014-09-14 15:42:18.843' AS DateTime), CAST(N'2014-09-14 15:42:18.843' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (76, N'Trạng thái sản phẩm', N'#/product-status', NULL, 71, NULL, 5, NULL, CAST(N'2014-09-14 15:42:50.760' AS DateTime), CAST(N'2014-09-14 15:42:50.760' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (77, N'Bài viết', N'javascript:;', N'icon-file-text', NULL, 1, 3, NULL, CAST(N'2014-09-14 15:43:46.773' AS DateTime), CAST(N'2014-09-14 15:43:46.773' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (78, N'Loại bài viết', N'#/article-type', NULL, 77, NULL, 1, NULL, CAST(N'2014-09-14 15:44:11.040' AS DateTime), CAST(N'2014-09-14 15:44:11.040' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (79, N'Nhóm bài viết', N'#/article-group', NULL, 77, NULL, 2, NULL, CAST(N'2014-09-14 15:44:39.960' AS DateTime), CAST(N'2014-09-14 15:44:39.960' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (80, N'Bài viết', N'#/article', NULL, 77, NULL, 3, NULL, CAST(N'2014-09-14 15:45:14.623' AS DateTime), CAST(N'2014-09-14 15:45:14.623' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (81, N'Hình ảnh', NULL, N'icon-picture', NULL, 1, 4, NULL, CAST(N'2014-09-14 15:45:59.703' AS DateTime), CAST(N'2014-09-14 15:45:59.703' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (82, N'Loại hình ảnh', N'#/picture-type', NULL, 81, 0, 1, NULL, CAST(N'2014-09-14 15:46:22.477' AS DateTime), CAST(N'2014-09-14 15:46:22.477' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (83, N'Hình ảnh', N'#/picture', NULL, 81, NULL, 2, NULL, CAST(N'2014-09-14 15:46:38.623' AS DateTime), CAST(N'2014-09-14 15:46:38.623' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (84, N'Đơn hàng', NULL, N'icon-money', NULL, 1, 5, NULL, CAST(N'2014-09-14 15:47:13.883' AS DateTime), CAST(N'2014-09-14 15:47:13.883' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (85, N'Đơn hàng', N'#/order', NULL, 84, NULL, 1, NULL, CAST(N'2014-09-14 15:47:35.400' AS DateTime), CAST(N'2014-09-14 15:47:35.400' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (86, N'Quảng cáo', NULL, N'icon-rss', NULL, 1, 5, NULL, CAST(N'2014-09-14 15:47:58.353' AS DateTime), CAST(N'2014-09-14 15:47:58.353' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (87, N'Quảng cáo', N'#/advertise', NULL, 86, NULL, 1, NULL, CAST(N'2014-09-14 15:49:39.277' AS DateTime), CAST(N'2014-09-14 15:49:39.277' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (88, N'Khách hàng', NULL, N'icon-group', NULL, 1, 7, NULL, CAST(N'2014-09-14 15:49:59.577' AS DateTime), CAST(N'2014-09-14 15:49:59.577' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (89, N'Khách hàng', N'#/customer', NULL, 88, NULL, 1, NULL, CAST(N'2014-09-14 15:50:17.057' AS DateTime), CAST(N'2014-09-14 15:50:17.057' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (90, N'Quản trị viên', NULL, N'icon-user', NULL, 1, 8, NULL, CAST(N'2014-09-14 15:50:48.777' AS DateTime), CAST(N'2014-09-14 15:50:48.777' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (91, N'Quản trị viên', N'#/user', NULL, 90, NULL, 1, NULL, CAST(N'2014-09-14 15:51:13.287' AS DateTime), CAST(N'2014-09-14 15:51:13.287' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (92, N'Quyền truy cập', N'#/role', NULL, 90, NULL, 2, NULL, CAST(N'2014-09-14 15:51:37.570' AS DateTime), CAST(N'2014-09-14 15:51:37.570' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (93, N'Trang truy cập', N'#/page', NULL, 90, NULL, 3, NULL, CAST(N'2014-09-14 15:51:55.720' AS DateTime), CAST(N'2014-09-14 15:51:55.720' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (94, N'Hệ thống', NULL, N'icon-cogs', NULL, 1, 9, NULL, CAST(N'2014-09-14 15:52:20.497' AS DateTime), CAST(N'2014-09-14 15:52:20.497' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (95, N'Nhóm hỗ trợ', N'#/support-type', NULL, 94, NULL, 1, NULL, CAST(N'2014-09-14 15:52:41.073' AS DateTime), CAST(N'2014-09-14 15:52:41.073' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (96, N'File', NULL, N'icon-file', NULL, 1, 10, NULL, CAST(N'2014-09-14 15:53:38.110' AS DateTime), CAST(N'2014-09-14 15:53:38.110' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (97, N'Loại file', N'#/file-type', NULL, 96, NULL, 1, NULL, CAST(N'2014-09-14 15:53:51.950' AS DateTime), CAST(N'2014-09-14 15:53:51.950' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (98, N'Hỗ trợ', N'#/support', NULL, 94, NULL, 1, NULL, CAST(N'2014-09-16 00:59:36.170' AS DateTime), CAST(N'2014-09-16 00:59:36.170' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (99, N'File', N'#/file', NULL, 96, NULL, 2, NULL, CAST(N'2014-09-18 00:19:40.240' AS DateTime), CAST(N'2014-09-18 00:19:40.240' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (100, N'Nhóm thuộc tính', N'#/product-group-attribute', NULL, 71, NULL, 6, NULL, CAST(N'2014-09-22 22:05:10.230' AS DateTime), CAST(N'2014-09-22 22:05:10.230' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (101, N'Thuộc tính sản phẩm', N'#/product-attribute', NULL, 71, NULL, 7, NULL, CAST(N'2014-09-22 22:05:45.813' AS DateTime), CAST(N'2014-09-22 22:05:45.813' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (102, N'Lọc sản phẩm', N'#/product-filter', NULL, 71, NULL, 8, NULL, CAST(N'2014-09-22 23:03:42.023' AS DateTime), CAST(N'2014-09-22 23:03:42.023' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (103, N'Nhãn sản phẩm', N'#/product-label', NULL, 71, NULL, 9, NULL, CAST(N'2014-09-22 23:45:44.740' AS DateTime), CAST(N'2014-09-22 23:45:44.740' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (104, N'Bố cục website', N'#/layout-content', NULL, 94, NULL, 4, NULL, CAST(N'2014-09-27 22:16:52.203' AS DateTime), CAST(N'2014-09-27 22:16:52.203' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (105, N'Liên hệ', N'#/contact', NULL, 94, NULL, 4, N'Liên hệ', CAST(N'2014-09-29 00:19:24.757' AS DateTime), CAST(N'2014-09-29 00:19:24.757' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (106, N'Nhóm nhận thông tin', N'#/receive-info-group', NULL, 94, NULL, 5, N'Nhóm nhận thông tin', CAST(N'2014-09-29 00:20:14.590' AS DateTime), CAST(N'2014-09-29 00:20:14.590' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (107, N'Nhận thông tin', N'#/receive-info', NULL, 94, NULL, 6, N'Nhận thông tin', CAST(N'2014-09-29 00:20:48.440' AS DateTime), CAST(N'2014-09-29 00:20:48.440' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (108, N'Nhóm loại bài vết', N'#/group-type-article', NULL, 77, NULL, 5, NULL, CAST(N'2014-10-04 01:36:09.967' AS DateTime), CAST(N'2014-10-04 01:36:09.967' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (109, N'Nhóm loại sản phẩm', N'#/product-type-group', NULL, 71, NULL, 5, NULL, CAST(N'2014-10-08 22:52:14.927' AS DateTime), CAST(N'2014-10-08 22:52:14.927' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (114, N'Menu', N'#/menu', NULL, 94, 0, 7, NULL, CAST(N'2015-03-08 10:28:42.587' AS DateTime), CAST(N'2015-03-08 10:28:42.587' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (115, N'Biến thể sản phẩm', N'#/product-variant', NULL, 71, NULL, 2, NULL, CAST(N'2015-03-08 21:02:01.847' AS DateTime), CAST(N'2015-03-08 21:02:01.847' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (116, N'Video', NULL, N'icon-film', NULL, 1, 12, NULL, CAST(N'2015-08-09 21:25:15.810' AS DateTime), CAST(N'2015-08-09 21:25:15.810' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (117, N'Video', N'#/video', NULL, 116, NULL, 1, NULL, CAST(N'2015-08-09 21:25:34.017' AS DateTime), CAST(N'2015-08-09 21:25:34.017' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[tblPage] ([ID], [Name], [Link], [ClassAtrtibute], [Parent], [HasChild], [Number], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (118, N'Loại video', N'#/video-type', NULL, 116, NULL, 2, NULL, CAST(N'2015-08-09 21:26:32.847' AS DateTime), CAST(N'2015-08-09 21:26:32.847' AS DateTime), NULL, NULL, 1, 0)
SET IDENTITY_INSERT [dbo].[tblPage] OFF
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 70)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 71)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 72)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 73)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 74)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 75)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 76)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 77)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 78)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 79)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 80)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 81)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 82)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 83)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 84)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 85)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 86)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 87)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 88)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 89)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 90)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 91)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 92)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 93)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 94)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 95)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 96)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 97)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 98)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 99)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 100)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 101)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 102)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 103)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 104)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 105)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 106)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 107)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 108)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 109)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 114)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 115)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 116)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 117)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (1, 118)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 70)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 71)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 72)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 73)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 77)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 78)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 79)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 80)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 81)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 82)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 83)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 84)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 85)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 86)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 87)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 88)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 89)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 94)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 102)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 104)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 105)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 108)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 114)
INSERT [dbo].[tblPage_Role] ([RoleId], [PageId]) VALUES (2, 115)
SET IDENTITY_INSERT [dbo].[UserProfile] ON 

INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (1, N'administrator', N'administrator', N'admin', 1, N'admin@gmail.com', N'0987456123', N'Hà Nội', N'Note', CAST(N'2014-09-14 00:00:00.000' AS DateTime), CAST(N'2014-09-14 00:00:00.000' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (3, N'admin', N'admin', N'admin', 1, N'admin@website.com', N'09874561', N'Hà Nội', NULL, CAST(N'2014-09-14 14:43:22.603' AS DateTime), CAST(N'2014-09-14 14:43:22.603' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (4, N'nammaianh', N'Mai Anh', N'Nam', 1, N'nammaianh@hotmail.com', N'01662029147', N'Tầng 5, số nhà 2 ngõ 21 Phan Chu Trinh- Phường Phan Chu Trinh - Quận Hoàn Kiếm- TP Hà Nội', NULL, CAST(N'2015-03-26 22:19:59.420' AS DateTime), CAST(N'2015-03-26 22:19:59.420' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (5, N'miraenguyen', N'Nguyễn Thị', N'Loan', 0, N'miraenguyen@hotmail.com ', N'0942481166', N'Tầng 5, số nhà 2 ngõ 21 Phan Chu Trinh- Phường Phan Chu Trinh - Quận Hoàn Kiếm- TP Hà Nội', NULL, CAST(N'2015-03-26 22:22:11.483' AS DateTime), CAST(N'2015-03-26 22:22:11.483' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (6, N'hongngoc_nta', N'Chị ', N'My', NULL, N'hongngoc_nta@yahoo.com', N'01676709686', N'Tầng 5, số nhà 2 ngõ 21 Phan Chu Trinh- Phường Phan Chu Trinh - Quận Hoàn Kiếm- TP Hà Nội', NULL, CAST(N'2015-03-26 22:23:21.360' AS DateTime), CAST(N'2015-03-26 22:23:21.360' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[UserProfile] ([UserId], [UserName], [FirstName], [LastName], [Gender], [Email], [Phone], [Address], [Note], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsActive], [IsDeleted]) VALUES (7, N'dohuong86', N'Chị ', N'Hương', NULL, N'dohuong86@gmail.com', N'0919184000', N'Tầng 5, số nhà 2 ngõ 21 Phan Chu Trinh- Phường Phan Chu Trinh - Quận Hoàn Kiếm- TP Hà Nội', NULL, CAST(N'2015-03-26 22:24:13.890' AS DateTime), CAST(N'2015-03-26 22:24:13.890' AS DateTime), NULL, NULL, 1, 0)
SET IDENTITY_INSERT [dbo].[UserProfile] OFF
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (1, CAST(N'2014-09-12 14:53:34.783' AS DateTime), NULL, 1, CAST(N'2015-04-19 16:57:14.493' AS DateTime), 0, N'AFUOWz9jnaOSlIThetF4GlDesZb7ggPOiXraHUTVmwdeL8shGxHrpgUAB4U7JxbHKA==', CAST(N'2015-08-09 14:29:20.310' AS DateTime), N'', NULL, NULL)
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (3, CAST(N'2014-09-14 07:43:22.790' AS DateTime), NULL, 1, CAST(N'2015-03-11 18:39:29.240' AS DateTime), 0, N'AF1cVHTHA0/ul1Iimp6eDnKlqYn67Kzdl4SWS2yBoruatIVMXR/sA3GPvgHL78uXtw==', CAST(N'2015-01-05 10:13:05.170' AS DateTime), N'', NULL, NULL)
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (4, CAST(N'2015-03-26 15:19:59.483' AS DateTime), NULL, 1, CAST(N'2015-03-26 15:27:08.980' AS DateTime), 0, N'AES+J/2PmioP4vwFVKTEC/9djuhcEuiBPjxee3E2PqYxtkulJYfp6KSI7C75+hE+uw==', CAST(N'2015-03-26 15:26:44.510' AS DateTime), N'', NULL, NULL)
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (5, CAST(N'2015-03-26 15:22:11.500' AS DateTime), NULL, 1, NULL, 0, N'AJJjN9vjU9AeJL3hfwQDlajPKd2nHn04UJ+KJxa69NdypEUrwhYlocQk7N/jgar24Q==', CAST(N'2015-03-26 15:22:11.500' AS DateTime), N'', NULL, NULL)
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (6, CAST(N'2015-03-26 15:23:21.377' AS DateTime), NULL, 1, CAST(N'2015-05-09 04:42:50.917' AS DateTime), 0, N'AFCFHg7ET157Cajw5AA40RUhYlJhIkE6eu3AuexMUHPPOgn66sc4w4KX7EHfjrPs9w==', CAST(N'2015-03-26 15:23:21.377' AS DateTime), N'', NULL, NULL)
INSERT [dbo].[webpages_Membership] ([UserId], [CreateDate], [ConfirmationToken], [IsConfirmed], [LastPasswordFailureDate], [PasswordFailuresSinceLastSuccess], [Password], [PasswordChangedDate], [PasswordSalt], [PasswordVerificationToken], [PasswordVerificationTokenExpirationDate]) VALUES (7, CAST(N'2015-03-26 15:24:13.907' AS DateTime), NULL, 1, NULL, 0, N'AH8+vsoD5ch74fIp4qbaufFFsjNnqlqeR34dEF1pA5QguD3bNFSeOxu796RLwioa+Q==', CAST(N'2015-03-26 15:24:13.907' AS DateTime), N'', NULL, NULL)
SET IDENTITY_INSERT [dbo].[webpages_Roles] ON 

INSERT [dbo].[webpages_Roles] ([RoleId], [RoleName], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (1, N'Administrator', N'Administrator', CAST(N'2014-09-12 23:11:20.310' AS DateTime), CAST(N'2014-09-12 23:11:20.310' AS DateTime), NULL, NULL, 1, 0)
INSERT [dbo].[webpages_Roles] ([RoleId], [RoleName], [Detail], [DateCreated], [DateUpdated], [CreateBy], [UpdateBy], [IsShow], [IsDeleted]) VALUES (2, N'Admin', NULL, CAST(N'2014-09-14 16:58:09.533' AS DateTime), CAST(N'2014-09-14 16:58:09.537' AS DateTime), NULL, NULL, 1, 0)
SET IDENTITY_INSERT [dbo].[webpages_Roles] OFF
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (1, 1)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (1, 2)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (3, 2)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (4, 2)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (5, 2)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (6, 2)
INSERT [dbo].[webpages_UsersInRoles] ([UserId], [RoleId]) VALUES (7, 2)
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__UserProf__C9F284563E37CAA2]    Script Date: 27/08/2015 6:34:55 CH ******/
ALTER TABLE [dbo].[UserProfile] ADD  CONSTRAINT [UQ__UserProf__C9F284563E37CAA2] UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__webpages__8A2B6160EA4A1CBF]    Script Date: 27/08/2015 6:34:55 CH ******/
ALTER TABLE [dbo].[webpages_Roles] ADD  CONSTRAINT [UQ__webpages__8A2B6160EA4A1CBF] UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblArticle] ADD  CONSTRAINT [DF_tblNews_Date]  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[tblComment] ADD  CONSTRAINT [DF_tblComment_Date]  DEFAULT (getdate()) FOR [Date]
GO
ALTER TABLE [dbo].[tblOrder] ADD  CONSTRAINT [DF_tblOrder_Date]  DEFAULT (getdate()) FOR [DateCreated]
GO
ALTER TABLE [dbo].[tblProduct] ADD  CONSTRAINT [DF_tblProduct_View]  DEFAULT ((0)) FOR [Viewed]
GO
ALTER TABLE [dbo].[tblAdverties_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblAdverties_Picture_tblAdvertise] FOREIGN KEY([AdvertiesID])
REFERENCES [dbo].[tblAdvertise] ([ID])
GO
ALTER TABLE [dbo].[tblAdverties_Picture_Map] CHECK CONSTRAINT [FK_tblAdverties_Picture_tblAdvertise]
GO
ALTER TABLE [dbo].[tblAdverties_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblAdverties_Picture_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblAdverties_Picture_Map] CHECK CONSTRAINT [FK_tblAdverties_Picture_tblPicture]
GO
ALTER TABLE [dbo].[tblArticle]  WITH NOCHECK ADD  CONSTRAINT [FK_tblArticle_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblArticle] CHECK CONSTRAINT [FK_tblArticle_tblPicture]
GO
ALTER TABLE [dbo].[tblArticle]  WITH NOCHECK ADD  CONSTRAINT [FK_tblNews_tblTypeNews] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypeArticle] ([ID])
GO
ALTER TABLE [dbo].[tblArticle] CHECK CONSTRAINT [FK_tblNews_tblTypeNews]
GO
ALTER TABLE [dbo].[tblArticle_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblArticle_Picture_Map_tblArticle] FOREIGN KEY([ArticleID])
REFERENCES [dbo].[tblArticle] ([ID])
GO
ALTER TABLE [dbo].[tblArticle_Picture_Map] CHECK CONSTRAINT [FK_tblArticle_Picture_Map_tblArticle]
GO
ALTER TABLE [dbo].[tblArticle_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblArticle_Picture_Map_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblArticle_Picture_Map] CHECK CONSTRAINT [FK_tblArticle_Picture_Map_tblPicture]
GO
ALTER TABLE [dbo].[tblComment]  WITH CHECK ADD  CONSTRAINT [FK_tblComment_tblAccount] FOREIGN KEY([AccountID])
REFERENCES [dbo].[tblCustomer] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblComment] CHECK CONSTRAINT [FK_tblComment_tblAccount]
GO
ALTER TABLE [dbo].[tblComment]  WITH CHECK ADD  CONSTRAINT [FK_tblComment_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblComment] CHECK CONSTRAINT [FK_tblComment_tblProduct]
GO
ALTER TABLE [dbo].[tblCustomer]  WITH CHECK ADD  CONSTRAINT [FK_tblCustomer_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblCustomer] CHECK CONSTRAINT [FK_tblCustomer_tblPicture]
GO
ALTER TABLE [dbo].[tblDistributor]  WITH CHECK ADD  CONSTRAINT [FK_tblDistributor_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblDistributor] CHECK CONSTRAINT [FK_tblDistributor_tblPicture]
GO
ALTER TABLE [dbo].[tblFile]  WITH CHECK ADD  CONSTRAINT [FK_tblFile_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblFile] CHECK CONSTRAINT [FK_tblFile_tblPicture]
GO
ALTER TABLE [dbo].[tblFile]  WITH CHECK ADD  CONSTRAINT [FK_tblFile_tblTypeFile] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypeFile] ([ID])
GO
ALTER TABLE [dbo].[tblFile] CHECK CONSTRAINT [FK_tblFile_tblTypeFile]
GO
ALTER TABLE [dbo].[tblGroup_Article_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblGroup_News_Map_tblGroupNews] FOREIGN KEY([GroupID])
REFERENCES [dbo].[tblGroupArticle] ([ID])
GO
ALTER TABLE [dbo].[tblGroup_Article_Map] CHECK CONSTRAINT [FK_tblGroup_News_Map_tblGroupNews]
GO
ALTER TABLE [dbo].[tblGroup_Article_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblGroup_News_Map_tblNews] FOREIGN KEY([NewsID])
REFERENCES [dbo].[tblArticle] ([ID])
GO
ALTER TABLE [dbo].[tblGroup_Article_Map] CHECK CONSTRAINT [FK_tblGroup_News_Map_tblNews]
GO
ALTER TABLE [dbo].[tblGroup_TypeArticle_Map]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGroup_TypeArticle_Map_tblGroupTypeArticle] FOREIGN KEY([GroupTypeID])
REFERENCES [dbo].[tblGroupTypeArticle] ([ID])
GO
ALTER TABLE [dbo].[tblGroup_TypeArticle_Map] CHECK CONSTRAINT [FK_tblGroup_TypeArticle_Map_tblGroupTypeArticle]
GO
ALTER TABLE [dbo].[tblGroup_TypeArticle_Map]  WITH NOCHECK ADD  CONSTRAINT [FK_tblGroup_TypeArticle_Map_tblTypeArticle] FOREIGN KEY([ArticleTypeID])
REFERENCES [dbo].[tblTypeArticle] ([ID])
GO
ALTER TABLE [dbo].[tblGroup_TypeArticle_Map] CHECK CONSTRAINT [FK_tblGroup_TypeArticle_Map_tblTypeArticle]
GO
ALTER TABLE [dbo].[tblGroupArticle]  WITH CHECK ADD  CONSTRAINT [FK_tblGroupNews_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblGroupArticle] CHECK CONSTRAINT [FK_tblGroupNews_tblPicture]
GO
ALTER TABLE [dbo].[tblGroupTypeArticle]  WITH CHECK ADD  CONSTRAINT [FK_tblGroupTypeArticle_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblGroupTypeArticle] CHECK CONSTRAINT [FK_tblGroupTypeArticle_tblPicture]
GO
ALTER TABLE [dbo].[tblLayoutContent]  WITH CHECK ADD  CONSTRAINT [FK_tblLayoutContent_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblLayoutContent] CHECK CONSTRAINT [FK_tblLayoutContent_tblPicture]
GO
ALTER TABLE [dbo].[tblManufacturer]  WITH CHECK ADD  CONSTRAINT [FK_tblManufacturer_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblManufacturer] CHECK CONSTRAINT [FK_tblManufacturer_tblPicture]
GO
ALTER TABLE [dbo].[tblMenu]  WITH CHECK ADD  CONSTRAINT [FK_tblMenu_tblMenu] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblMenu] ([ID])
GO
ALTER TABLE [dbo].[tblMenu] CHECK CONSTRAINT [FK_tblMenu_tblMenu]
GO
ALTER TABLE [dbo].[tblOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblOrder_tblCustomer] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[tblCustomer] ([ID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK_tblOrder_tblCustomer]
GO
ALTER TABLE [dbo].[tblOrder]  WITH CHECK ADD  CONSTRAINT [FK_tblOrder_tblOrder_Status] FOREIGN KEY([OrderStatusID])
REFERENCES [dbo].[tblOrder_Status] ([ID])
GO
ALTER TABLE [dbo].[tblOrder] CHECK CONSTRAINT [FK_tblOrder_tblOrder_Status]
GO
ALTER TABLE [dbo].[tblOrder_Shipping]  WITH CHECK ADD  CONSTRAINT [FK_tblOrder_Shipping_tblOrder] FOREIGN KEY([OrderID])
REFERENCES [dbo].[tblOrder] ([ID])
GO
ALTER TABLE [dbo].[tblOrder_Shipping] CHECK CONSTRAINT [FK_tblOrder_Shipping_tblOrder]
GO
ALTER TABLE [dbo].[tblOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblOrderDetail_tblOrder] FOREIGN KEY([OrderID])
REFERENCES [dbo].[tblOrder] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblOrderDetail] CHECK CONSTRAINT [FK_tblOrderDetail_tblOrder]
GO
ALTER TABLE [dbo].[tblOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblOrderDetail_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblOrderDetail] CHECK CONSTRAINT [FK_tblOrderDetail_tblProduct]
GO
ALTER TABLE [dbo].[tblOrderDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblOrderDetail_tblProduct_Variant] FOREIGN KEY([ProductVariantID])
REFERENCES [dbo].[tblProduct_Variant] ([ID])
GO
ALTER TABLE [dbo].[tblOrderDetail] CHECK CONSTRAINT [FK_tblOrderDetail_tblProduct_Variant]
GO
ALTER TABLE [dbo].[tblPage]  WITH CHECK ADD  CONSTRAINT [FK_tblPage_tblPage] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblPage] ([ID])
GO
ALTER TABLE [dbo].[tblPage] CHECK CONSTRAINT [FK_tblPage_tblPage]
GO
ALTER TABLE [dbo].[tblPage_Role]  WITH CHECK ADD  CONSTRAINT [FK_tblPage_Role_tblPage] FOREIGN KEY([PageId])
REFERENCES [dbo].[tblPage] ([ID])
GO
ALTER TABLE [dbo].[tblPage_Role] CHECK CONSTRAINT [FK_tblPage_Role_tblPage]
GO
ALTER TABLE [dbo].[tblPage_Role]  WITH CHECK ADD  CONSTRAINT [FK_tblPage_Role_webpages_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[webpages_Roles] ([RoleId])
GO
ALTER TABLE [dbo].[tblPage_Role] CHECK CONSTRAINT [FK_tblPage_Role_webpages_Roles]
GO
ALTER TABLE [dbo].[tblPicture]  WITH CHECK ADD  CONSTRAINT [FK_tblImage_tblTypeImage] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypePicture] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblPicture] CHECK CONSTRAINT [FK_tblImage_tblTypeImage]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblDistributor] FOREIGN KEY([Distributor])
REFERENCES [dbo].[tblDistributor] ([ID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblDistributor]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblManufacturer] FOREIGN KEY([Manufacturer])
REFERENCES [dbo].[tblManufacturer] ([ID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblManufacturer]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblPicture]
GO
ALTER TABLE [dbo].[tblProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_tblTypeProduct] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypeProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct] CHECK CONSTRAINT [FK_tblProduct_tblTypeProduct]
GO
ALTER TABLE [dbo].[tblProduct_Attribute_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Attribute_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Attribute_Map] CHECK CONSTRAINT [FK_tblProduct_Attribute_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Attribute_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Attribute_Map_tblProductAttribute] FOREIGN KEY([AttributeID])
REFERENCES [dbo].[tblProductAttribute] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Attribute_Map] CHECK CONSTRAINT [FK_tblProduct_Attribute_Map_tblProductAttribute]
GO
ALTER TABLE [dbo].[tblProduct_File_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_File_Map_tblPicture] FOREIGN KEY([FileID])
REFERENCES [dbo].[tblFile] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_File_Map] CHECK CONSTRAINT [FK_tblProduct_File_Map_tblPicture]
GO
ALTER TABLE [dbo].[tblProduct_File_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_File_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_File_Map] CHECK CONSTRAINT [FK_tblProduct_File_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Filter_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Filter_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Filter_Map] CHECK CONSTRAINT [FK_tblProduct_Filter_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Filter_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Filter_Map_tblProductFilter] FOREIGN KEY([FilterID])
REFERENCES [dbo].[tblProductFilter] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Filter_Map] CHECK CONSTRAINT [FK_tblProduct_Filter_Map_tblProductFilter]
GO
ALTER TABLE [dbo].[tblProduct_Label_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Label_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Label_Map] CHECK CONSTRAINT [FK_tblProduct_Label_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Label_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Label_Map_tblProductLabel] FOREIGN KEY([ProductLabelID])
REFERENCES [dbo].[tblProductLabel] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Label_Map] CHECK CONSTRAINT [FK_tblProduct_Label_Map_tblProductLabel]
GO
ALTER TABLE [dbo].[tblProduct_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Picture_Map_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Picture_Map] CHECK CONSTRAINT [FK_tblProduct_Picture_Map_tblPicture]
GO
ALTER TABLE [dbo].[tblProduct_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Picture_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Picture_Map] CHECK CONSTRAINT [FK_tblProduct_Picture_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Status_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Status_Map_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Status_Map] CHECK CONSTRAINT [FK_tblProduct_Status_Map_tblProduct]
GO
ALTER TABLE [dbo].[tblProduct_Status_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Status_Map_tblProductStatus] FOREIGN KEY([ProductStatusID])
REFERENCES [dbo].[tblProductStatus] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Status_Map] CHECK CONSTRAINT [FK_tblProduct_Status_Map_tblProductStatus]
GO
ALTER TABLE [dbo].[tblProduct_Variant]  WITH CHECK ADD  CONSTRAINT [FK_tblProduct_Variant_tblProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[tblProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProduct_Variant] CHECK CONSTRAINT [FK_tblProduct_Variant_tblProduct]
GO
ALTER TABLE [dbo].[tblProductAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tblProductAttribute_tblProductGroupAttribute] FOREIGN KEY([GroupID])
REFERENCES [dbo].[tblProductGroupAttribute] ([ID])
GO
ALTER TABLE [dbo].[tblProductAttribute] CHECK CONSTRAINT [FK_tblProductAttribute_tblProductGroupAttribute]
GO
ALTER TABLE [dbo].[tblProductFilter]  WITH CHECK ADD  CONSTRAINT [FK_tblProductFilter_tblProductFilter] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblProductFilter] ([ID])
GO
ALTER TABLE [dbo].[tblProductFilter] CHECK CONSTRAINT [FK_tblProductFilter_tblProductFilter]
GO
ALTER TABLE [dbo].[tblProductGroupAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tblProductGroupAttribute_tblTypeProduct] FOREIGN KEY([ProductTypeID])
REFERENCES [dbo].[tblTypeProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProductGroupAttribute] CHECK CONSTRAINT [FK_tblProductGroupAttribute_tblTypeProduct]
GO
ALTER TABLE [dbo].[tblProductLabel]  WITH CHECK ADD  CONSTRAINT [FK_tblProductLabel_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblProductLabel] CHECK CONSTRAINT [FK_tblProductLabel_tblPicture]
GO
ALTER TABLE [dbo].[tblProductType_Group_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProductType_Group_Map_tblProductTypeGroup] FOREIGN KEY([GroupTypeID])
REFERENCES [dbo].[tblProductTypeGroup] ([ID])
GO
ALTER TABLE [dbo].[tblProductType_Group_Map] CHECK CONSTRAINT [FK_tblProductType_Group_Map_tblProductTypeGroup]
GO
ALTER TABLE [dbo].[tblProductType_Group_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblProductType_Group_Map_tblTypeProduct] FOREIGN KEY([ProductTypeID])
REFERENCES [dbo].[tblTypeProduct] ([ID])
GO
ALTER TABLE [dbo].[tblProductType_Group_Map] CHECK CONSTRAINT [FK_tblProductType_Group_Map_tblTypeProduct]
GO
ALTER TABLE [dbo].[tblReceiveInfo]  WITH CHECK ADD  CONSTRAINT [FK_tblReceiveInfo_tblReceiveInfoGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[tblReceiveInfoGroup] ([ID])
GO
ALTER TABLE [dbo].[tblReceiveInfo] CHECK CONSTRAINT [FK_tblReceiveInfo_tblReceiveInfoGroup]
GO
ALTER TABLE [dbo].[tblSupport]  WITH CHECK ADD  CONSTRAINT [FK_tblSupport_tblTypeSupport] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypeSupport] ([ID])
GO
ALTER TABLE [dbo].[tblSupport] CHECK CONSTRAINT [FK_tblSupport_tblTypeSupport]
GO
ALTER TABLE [dbo].[tblTypeArticle]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTypeArticle_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypeArticle] CHECK CONSTRAINT [FK_tblTypeArticle_tblPicture]
GO
ALTER TABLE [dbo].[tblTypeArticle]  WITH NOCHECK ADD  CONSTRAINT [FK_tblTypeArticle_tblTypeArticle] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblTypeArticle] ([ID])
GO
ALTER TABLE [dbo].[tblTypeArticle] CHECK CONSTRAINT [FK_tblTypeArticle_tblTypeArticle]
GO
ALTER TABLE [dbo].[tblTypeFile]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeFile_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypeFile] CHECK CONSTRAINT [FK_tblTypeFile_tblPicture]
GO
ALTER TABLE [dbo].[tblTypeFile]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeFile_tblTypeFile] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblTypeFile] ([ID])
GO
ALTER TABLE [dbo].[tblTypeFile] CHECK CONSTRAINT [FK_tblTypeFile_tblTypeFile]
GO
ALTER TABLE [dbo].[tblTypePicture]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeImage_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypePicture] CHECK CONSTRAINT [FK_tblTypeImage_tblPicture]
GO
ALTER TABLE [dbo].[tblTypePicture]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeImage_tblTypeImage] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblTypePicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypePicture] CHECK CONSTRAINT [FK_tblTypeImage_tblTypeImage]
GO
ALTER TABLE [dbo].[tblTypeProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeProduct_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypeProduct] CHECK CONSTRAINT [FK_tblTypeProduct_tblPicture]
GO
ALTER TABLE [dbo].[tblTypeProduct]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeProduct_tblTypeProduct1] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblTypeProduct] ([ID])
GO
ALTER TABLE [dbo].[tblTypeProduct] CHECK CONSTRAINT [FK_tblTypeProduct_tblTypeProduct1]
GO
ALTER TABLE [dbo].[tblTypeProduct_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeProduct_Picture_Map_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypeProduct_Picture_Map] CHECK CONSTRAINT [FK_tblTypeProduct_Picture_Map_tblPicture]
GO
ALTER TABLE [dbo].[tblTypeProduct_Picture_Map]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeProduct_Picture_Map_tblTypeProduct] FOREIGN KEY([ProductTypeID])
REFERENCES [dbo].[tblTypeProduct] ([ID])
GO
ALTER TABLE [dbo].[tblTypeProduct_Picture_Map] CHECK CONSTRAINT [FK_tblTypeProduct_Picture_Map_tblTypeProduct]
GO
ALTER TABLE [dbo].[tblTypeVideo]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeVideo_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblTypeVideo] CHECK CONSTRAINT [FK_tblTypeVideo_tblPicture]
GO
ALTER TABLE [dbo].[tblTypeVideo]  WITH CHECK ADD  CONSTRAINT [FK_tblTypeVideo_tblTypeVideo] FOREIGN KEY([Parent])
REFERENCES [dbo].[tblTypeVideo] ([ID])
GO
ALTER TABLE [dbo].[tblTypeVideo] CHECK CONSTRAINT [FK_tblTypeVideo_tblTypeVideo]
GO
ALTER TABLE [dbo].[tblVideo]  WITH CHECK ADD  CONSTRAINT [FK_tblVideo_tblFile] FOREIGN KEY([FileID])
REFERENCES [dbo].[tblFile] ([ID])
GO
ALTER TABLE [dbo].[tblVideo] CHECK CONSTRAINT [FK_tblVideo_tblFile]
GO
ALTER TABLE [dbo].[tblVideo]  WITH CHECK ADD  CONSTRAINT [FK_tblVideo_tblPicture] FOREIGN KEY([PictureID])
REFERENCES [dbo].[tblPicture] ([ID])
GO
ALTER TABLE [dbo].[tblVideo] CHECK CONSTRAINT [FK_tblVideo_tblPicture]
GO
ALTER TABLE [dbo].[tblVideo]  WITH CHECK ADD  CONSTRAINT [FK_tblVideo_tblTypeVideo] FOREIGN KEY([TypeID])
REFERENCES [dbo].[tblTypeVideo] ([ID])
GO
ALTER TABLE [dbo].[tblVideo] CHECK CONSTRAINT [FK_tblVideo_tblTypeVideo]
GO
ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[webpages_Roles] ([RoleId])
GO
ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_RoleId]
GO
ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO
ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_UserId]
GO
/****** Object:  StoredProcedure [dbo].[PRC_AllChildTypeNews]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_AllChildTypeNews]
(
	@CategoryAscii nvarchar(255)
)
AS
BEGIN
	WITH ListTypeNews (ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted, PictureID)
	AS
	(
		SELECT ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted, PictureID
		FROM tblTypeArticle t
		WHERE t.NameAscii IN (SELECT * FROM [dbo].[SplitString](@CategoryAscii, ',')) AND t.IsShow = 1 AND t.IsDeleted = 0
		UNION ALL
		SELECT c.ID, c.Name, c.NameAscii, c.SEOTitle, c.SEODescription, c.SEOKeyword, c.Parent, c.Number, c.IsShow, c.IsDeleted, c.PictureID
		FROM tblTypeArticle AS c
		INNER JOIN ListTypeNews AS d ON c.Parent = d.ID
	)
	SELECT DISTINCT t.*, p.[FileName] AS UrlPicture FROM ListTypeNews t
	LEFT JOIN tblPicture p ON p.ID = t.PictureID
	WHERE t.IsDeleted = 0 AND t.IsShow = 1	
END














GO
/****** Object:  StoredProcedure [dbo].[PRC_AllChildTypeNewsByArrID]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_AllChildTypeNewsByArrID]
(
	@ListID nvarchar(255)
)
AS
BEGIN
	WITH ListTypeNews (ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted)
	AS
	(
		SELECT ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted
		FROM tblTypeArticle
		WHERE ID IN (SELECT * FROM [dbo].[SplitString](@ListID, ','))
		UNION ALL
		SELECT c.ID, c.Name, c.NameAscii, c.SEOTitle, c.SEODescription, c.SEOKeyword, c.Parent, c.Number, c.IsShow, c.IsDeleted
		FROM tblTypeArticle AS c
		INNER JOIN ListTypeNews AS d ON c.Parent = d.ID		
	)
	SELECT DISTINCT * FROM ListTypeNews WHERE IsDeleted = 0 AND IsShow = 1 ORDER BY Number DESC, ID DESC
END













GO
/****** Object:  StoredProcedure [dbo].[PRC_FilterByParentAscii]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_FilterByParentAscii]
(
	@Ascii nvarchar(255),
	@LanguageId int
)
AS
BEGIN

	WITH ListFilter (ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted)
	AS
	(
		SELECT ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted
		FROM tblProductFilter
		WHERE NameAscii = @Ascii AND LanguageId = @LanguageId
		UNION ALL
		SELECT c.ID, c.Name, c.NameAscii, c.Parent, c.Number, c.IsShow, c.IsDeleted
		FROM tblProductFilter AS c
		INNER JOIN ListFilter AS d ON c.Parent = d.ID		
	)
	SELECT DISTINCT t.ID, t.Name, t.NameAscii, t.Parent, t.Number, t.IsShow, t.IsDeleted, f.Name AS ParentName, f.NameAscii AS ParentAscii FROM ListFilter t
	LEFT JOIN tblProductFilter f ON t.Parent = f.ID
	WHERE t.IsDeleted = 0 AND t.IsShow = 1 ORDER BY t.Number DESC, t.ID DESC

END
GO
/****** Object:  StoredProcedure [dbo].[PRC_FilterByParentId]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_FilterByParentId]
(
	@ListID nvarchar(255),
	@LanguageId int
)
AS
BEGIN

	IF @ListID = '0'
	BEGIN
		WITH ListFilter (ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted)
		AS
		(
			SELECT ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted
			FROM tblProductFilter
			WHERE Parent IS NULL AND LanguageId = @LanguageId
			UNION ALL
			SELECT c.ID, c.Name, c.NameAscii, c.Parent, c.Number, c.IsShow, c.IsDeleted
			FROM tblProductFilter AS c
			INNER JOIN ListFilter AS d ON c.Parent = d.ID		
		)
		SELECT DISTINCT * FROM ListFilter WHERE IsDeleted = 0 AND IsShow = 1 ORDER BY Number DESC, ID DESC
	END
	ELSE
	BEGIN
		WITH ListFilter (ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted)
		AS
		(
			SELECT ID, Name, NameAscii, Parent, Number, IsShow, IsDeleted
			FROM tblProductFilter
			WHERE Parent IN (SELECT * FROM [dbo].[SplitString](@ListID, ','))  AND LanguageId = @LanguageId
			UNION ALL
			SELECT c.ID, c.Name, c.NameAscii, c.Parent, c.Number, c.IsShow, c.IsDeleted
			FROM tblProductFilter AS c
			INNER JOIN ListFilter AS d ON c.Parent = d.ID		
		)
		SELECT DISTINCT * FROM ListFilter WHERE IsDeleted = 0 AND IsShow = 1 ORDER BY Number DESC, ID DESC
	END

END
GO
/****** Object:  StoredProcedure [dbo].[PRC_GetListNewsByType]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_GetListNewsByType]
(
	@TypeID int,
	@TypeAscii nvarchar(255),
	@Language int,
	@CurrentRecord int = 0,
	@PageSize int = 30,
	@Total int OUTPUT
)
AS
BEGIN

	WITH ListTypeNews (ID, IsShow, IsDeleted)
	AS
	(
		SELECT ID, IsShow, IsDeleted
		FROM tblTypeArticle
		WHERE ID = @TypeID OR NameAscii = @TypeAscii AND LanguageId = @Language
		UNION ALL
		SELECT c.ID, c.IsShow, c.IsDeleted
		FROM tblTypeArticle AS c
		INNER JOIN ListTypeNews AS d ON c.Parent = d.ID
		WHERE LanguageId = @Language
	)
	SELECT DISTINCT * INTO #TempTypeNews FROM ListTypeNews WHERE IsDeleted = 0 AND IsShow = 1

	SET @Total = (SELECT COUNT(*) FROM tblArticle WHERE TypeID IN (SELECT ID FROM #TempTypeNews) AND IsShow = 1 AND IsDeleted = 0)

	SELECT TOP(@PageSize) * FROM 
	(
		SELECT ROW_NUMBER() OVER(ORDER BY a.Number DESC, a.ID DESC) AS RowNumber, 
		a.ID, 
		a.Title,
		a.TitleAscii,
		a.Number,
		a.Summary,
		a.DateCreated,
		p.[FileName] AS PictureURL,
		t.Name AS TypeName,
		t.NameAscii AS TypeNameAscii,
		t1.Name AS TypeParentName,
		t1.NameAscii AS TypeParentNameAscii
		FROM tblArticle a
		LEFT JOIN tblTypeArticle t ON t.ID = a.TypeID
		LEFT JOIN tblTypeArticle t1 ON t1.ID = t.Parent
		LEFT JOIN tblPicture p ON p.ID = a.PictureID
		WHERE a.TypeID IN (SELECT ID FROM #TempTypeNews)		
		AND a.IsShow = 1
		AND a.IsDeleted = 0		
	) t
	WHERE t.RowNumber > @CurrentRecord
	ORDER BY t.ID DESC

	DROP TABLE #TempTypeNews

END



GO
/****** Object:  StoredProcedure [dbo].[PRC_GetListProductByType]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_GetListProductByType]
(
	@TypeID int,
	@TypeAscii nvarchar(255),
	@Language int,
	@CurrentRecord int = 0,
	@PageSize int = 30,
	@Total int OUTPUT
)
AS
BEGIN

	WITH ListTypeProduct (ID, IsShow, IsDeleted)
	AS
	(
		SELECT ID, IsShow, IsDeleted
		FROM tblTypeProduct
		WHERE ID = @TypeID OR NameAscii = @TypeAscii AND LanguageId = @Language
		UNION ALL
		SELECT c.ID, c.IsShow, c.IsDeleted
		FROM tblTypeProduct AS c
		INNER JOIN ListTypeProduct AS d ON c.Parent = d.ID
		WHERE LanguageId = @Language
	)
	SELECT DISTINCT * INTO #TempTypeProduct FROM ListTypeProduct WHERE IsDeleted = 0 AND IsShow = 1

	SET @Total = (SELECT COUNT(ID) FROM tblProduct WHERE TypeID IN (SELECT ID FROM #TempTypeProduct) AND IsShow = 1 AND IsDeleted = 0)

	SELECT TOP(@PageSize) * FROM 
	(
		SELECT ROW_NUMBER() OVER(ORDER BY p.Number DESC, p.ID DESC) AS RowNumber, 
		p.ID, 
		p.Name,
		p.NameAscii,
		p.Number,
		p.Price,
		p.Serial,
		pt.[FileName] AS UrlPicture,
		t.ID AS TypeID,
		t.Name AS TypeName,
		t.NameAscii AS TypeNameAscii,
		b.ID AS BrandID,
		b.Name AS BrandName,
		b.NameAscii AS BrandNameAscii
		FROM tblProduct p
		LEFT JOIN tblTypeProduct t ON t.ID = p.TypeID
		LEFT JOIN tblManufacturer b ON b.ID = p.Manufacturer
		LEFT JOIN tblPicture pt ON pt.ID = p.PictureID
		WHERE p.TypeID IN (SELECT ID FROM #TempTypeProduct)		
		AND p.IsShow = 1
		AND p.IsDeleted = 0		
	) t
	WHERE t.RowNumber > @CurrentRecord
	ORDER BY t.ID DESC

	DROP TABLE #TempTypeProduct

END
GO
/****** Object:  StoredProcedure [dbo].[PRC_GetMenu]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_GetMenu]
	@UserId int
AS
	SELECT DISTINCT p.ID, p.Name, p.Link, p.ClassAtrtibute, p.Parent, p.HasChild, p.Number FROM webpages_UsersInRoles u
	INNER JOIN tblPage_Role r ON u.RoleId = r.RoleId
	INNER JOIN tblPage p ON r.PageId = p.ID
	WHERE u.UserId = @UserId



















GO
/****** Object:  StoredProcedure [dbo].[PRC_InsertFilterForProduct]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_InsertFilterForProduct]
	@ProductId int, 
	@FilterId nvarchar(1000)
AS
BEGIN
	
	DELETE tblProduct_Filter_Map
	WHERE ProductID = @ProductID

	IF LEN(@FilterId) > 0
	BEGIN
		
		INSERT INTO tblProduct_Filter_Map(ProductID, FilterID)
			SELECT @ProductID, Value FROM [dbo].[SplitStringWithOrder](@FilterId, ',') ORDER BY DisplayOrder ASC

	END	

END



GO
/****** Object:  StoredProcedure [dbo].[PRC_InsertLabelForProduct]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_InsertLabelForProduct]
	@ProductId int, 
	@LabelId int
AS
	INSERT INTO tblProduct_Label_Map
		VALUES (@ProductId, @LabelId)



















GO
/****** Object:  StoredProcedure [dbo].[PRC_InsertPageForRole]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_InsertPageForRole]
	@RoleId int, 
	@PageId int
AS
	INSERT INTO tblPage_Role
		VALUES (@RoleId, @PageId)



















GO
/****** Object:  StoredProcedure [dbo].[PRC_InsertRoleForUser]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_InsertRoleForUser]
	@UserId int, 
	@RoleId int
AS
	INSERT INTO webpages_UsersInRoles
		VALUES (@UserId, @RoleId)



















GO
/****** Object:  StoredProcedure [dbo].[PRC_MenuByParentId]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_MenuByParentId]
(
	@ListID nvarchar(255)
)
AS
BEGIN

	IF @ListID = '0'
	BEGIN
		WITH ListMenu (ID, Name, NameAscii, Link, [Target], CssClass, Parent, Number, IsShow, IsDeleted)
		AS
		(
			SELECT ID, Name, NameAscii, Link, [Target], CssClass, Parent, DisplayOrder, IsShow, IsDeleted
			FROM tblMenu
			WHERE Parent IS NULL
			UNION ALL
			SELECT c.ID, c.Name, c.NameAscii, c.Link, c.[Target], c.CssClass, c.Parent, c.DisplayOrder, c.IsShow, c.IsDeleted
			FROM tblMenu AS c
			INNER JOIN ListMenu AS d ON c.Parent = d.ID		
		)
		SELECT DISTINCT * FROM ListMenu WHERE IsDeleted = 0 AND IsShow = 1 ORDER BY Number DESC, ID DESC
	END
	ELSE
	BEGIN
		WITH ListMenu (ID, Name, NameAscii, Link, [Target], CssClass, Parent, Number, IsShow, IsDeleted)
		AS
		(
			SELECT ID, Name, NameAscii, Link, [Target], CssClass, Parent, DisplayOrder, IsShow, IsDeleted
			FROM tblMenu
			WHERE Parent IN (SELECT * FROM [dbo].[SplitString](@ListID, ','))
			UNION ALL
			SELECT c.ID, c.Name, c.NameAscii, c.Link, c.[Target], c.CssClass, c.Parent, c.DisplayOrder, c.IsShow, c.IsDeleted
			FROM tblMenu AS c
			INNER JOIN ListMenu AS d ON c.Parent = d.ID		
		)
		SELECT DISTINCT * FROM ListMenu WHERE IsDeleted = 0 AND IsShow = 1 ORDER BY Number DESC, ID DESC
	END

END







GO
/****** Object:  StoredProcedure [dbo].[PRC_Product_GetAllChildTypeByParentID]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_Product_GetAllChildTypeByParentID]
(
	@Parent int
)
AS
BEGIN
	WITH ListTyperoduct (ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted, PictureID)
	AS
	(
		SELECT ID, Name, NameAscii, SEOTitle, SEODescription, SEOKeyword, Parent, Number, IsShow, IsDeleted, PictureID
		FROM tblTypeProduct t
		WHERE t.ID = @Parent AND t.IsShow = 1 AND t.IsDeleted = 0
		UNION ALL
		SELECT c.ID, c.Name, c.NameAscii, c.SEOTitle, c.SEODescription, c.SEOKeyword, c.Parent, c.Number, c.IsShow, c.IsDeleted, c.PictureID
		FROM tblTypeProduct AS c
		INNER JOIN ListTyperoduct AS d ON c.Parent = d.ID
	)
	SELECT DISTINCT t.*, p.[FileName] AS UrlPicture FROM ListTyperoduct t
	LEFT JOIN tblPicture p ON p.ID = t.PictureID
	WHERE t.IsDeleted = 0 AND t.IsShow = 1
	ORDER BY t.Number DESC, t.ID DESC
END






GO
/****** Object:  StoredProcedure [dbo].[PRC_Product_GetProductByType]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_Product_GetProductByType]
(
	@TypeID int,
	@TypeAscii nvarchar(255),
	@Skip int,
	@Top int,
	@Total int OUTPUT
)
AS
BEGIN	

	WITH ListTypeProduct (ID, Parent)
	AS
	(
		SELECT ID, Parent
		FROM tblTypeProduct t
		WHERE (t.ID = @TypeID OR (@TypeID = 0 AND t.NameAscii = @TypeAscii)) AND t.IsShow = 1 AND t.IsDeleted = 0
		UNION ALL
		SELECT c.ID, c.Parent
		FROM tblTypeProduct AS c
		INNER JOIN ListTypeProduct AS d ON c.Parent = d.ID
		WHERE c.IsShow = 1 AND c.IsDeleted = 0
	)
	SELECT DISTINCT ID INTO #TempID FROM ListTypeProduct

	SET @Total = (SELECT COUNT(ID) FROM tblProduct WHERE TypeID IN (SELECT ID FROM #TempID) AND IsDeleted = 0 AND IsShow = 1)

	;WITH TempProduct(RowNumber,ID,Name,NameAscii,Serial,TypeID,Manufacturer,Distributor,Price,Quantity,PictureID,HighLights,Summary,Detail,Number,Viewed,SEOTitle,SEODescription,SEOKeyword,DateCreated,DateUpdated,CreateBy,UpdateBy,IsShow,IsDeleted,URLPicture) AS
	(
		SELECT 
		ROW_NUMBER() OVER(ORDER BY p.Number DESC, p.ID DESC) AS RowNumber,
		p.ID,
		p.[Name],
		t2.NameAscii + '/' + t1.NameAscii + '/' + p.[NameAscii] AS NameAscii,
		p.[Serial],
		p.[TypeID],
		p.[Manufacturer],
		p.[Distributor],
		p.[Price],
		p.[Quantity],
		p.[PictureID],
		p.[HighLights],
		p.[Summary],
		p.[Detail],
		p.[Number],
		p.[Viewed],
		p.[SEOTitle],
		p.[SEODescription],
		p.[SEOKeyword],
		p.[DateCreated],
		p.[DateUpdated],
		p.[CreateBy],
		p.[UpdateBy],
		p.[IsShow],
		p.[IsDeleted],
		pt.[FileName] AS URLPicture 
		FROM tblProduct p
		INNER JOIN tblTypeProduct t1 ON p.TypeID = t1.ID
		INNER JOIN tblTypeProduct t2 ON t2.ID = t1.Parent
		INNER JOIN tblPicture pt ON pt.ID = p.PictureID
		WHERE p.TypeID IN (SELECT ID FROM #TempID) 
		AND p.IsDeleted = 0 
		AND p.IsShow = 1
	)
	SELECT TOP (@Top) * FROM TempProduct
	WHERE RowNumber > @Skip

	DROP TABLE #TempID

END
GO
/****** Object:  StoredProcedure [dbo].[PRC_ResetFileProduct]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PRC_ResetFileProduct]
(
	@ProductID int,
	@ListID nvarchar(255)
)
AS
BEGIN
	
	DELETE tblProduct_File_Map
	WHERE ProductID = @ProductID

	IF LEN(@ListID) > 0
	BEGIN	

		INSERT INTO tblProduct_File_Map(ProductID, FileID)
		SELECT @ProductID, Value FROM [dbo].[SplitStringWithOrder](@ListID, ',') ORDER BY DisplayOrder ASC		

	END	

END






GO
/****** Object:  StoredProcedure [dbo].[PRC_ResetPictureArticle]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_ResetPictureArticle]
(
	@ArticleID int,
	@ListID nvarchar(255)
)
AS
BEGIN
	

	IF LEN(@ListID) > 0
	BEGIN
		
		DELETE tblArticle_Picture_Map
		WHERE ArticleID = @ArticleID

		INSERT INTO tblArticle_Picture_Map(ArticleID, PictureID)
		SELECT @ArticleID, Value FROM [dbo].[SplitStringWithOrder](@ListID, ',') ORDER BY DisplayOrder ASC		

	END	

END










GO
/****** Object:  StoredProcedure [dbo].[PRC_ResetPictureProduct]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_ResetPictureProduct]
(
	@ProductID int,
	@ListID nvarchar(255)
)
AS
BEGIN
	
	DELETE tblProduct_Picture_Map
	WHERE ProductID = @ProductID

	IF LEN(@ListID) > 0
	BEGIN
		
		INSERT INTO tblProduct_Picture_Map(ProductID, PictureID)
		SELECT @ProductID, Value FROM [dbo].[SplitStringWithOrder](@ListID, ',') ORDER BY DisplayOrder ASC

	END	

END



GO
/****** Object:  StoredProcedure [dbo].[PRC_ResetPictureProductType]    Script Date: 27/08/2015 6:34:55 CH ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PRC_ResetPictureProductType]
(
	@TypeID int,
	@ListID nvarchar(255)
)
AS
BEGIN
	
	DELETE tblTypeProduct_Picture_Map
	WHERE ProductTypeID = @TypeID

	IF LEN(@ListID) > 0
	BEGIN
		
		INSERT INTO tblTypeProduct_Picture_Map(ProductTypeID, PictureID)
		SELECT @TypeID, Name FROM [dbo].[SplitString](@ListID, ',')

	END	

END







GO
USE [master]
GO
ALTER DATABASE [web365] SET  READ_WRITE 
GO
