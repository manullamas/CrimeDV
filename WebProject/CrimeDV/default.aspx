<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="CrimeDV.defaultpage" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>London Crime Data Visualiser</title>

    <link href='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.css' rel='stylesheet' />
    <link rel="stylesheet" type="text/css" href="/styles/main.css" />
    <script src="/scripts/d3.min.js" charset="utf-8"></script>
    <script src='https://api.mapbox.com/mapbox.js/v2.2.3/mapbox.js'></script>
    <meta name="description" content="London crime data visualiser. Includes points of interest and demographics." />
</head>
<body>
    <form id="form1" runat="server">
        <div class="header row">
            <div class="headertitle">
                <table class="headerTable"><tr><td class="headerText">London Crime Data Visualiser</td>
                    <td class="headerNav">
                        <a href="/" class="navText"> Dashboard </a> | <a href="/mapn.aspx" class="navText">By Number</a> | <a href="/mapd.aspx" class="navText">By Density</a> | <a href="/mapb.aspx" class="navText">By Borrough</a></td></tr></table>
            </div>
        </div>
        <div class="body row" id="crimemap">
            <iframe src="http://taoufikds.cloudapp.net:5000" style="width:100%;height:100%;" ></iframe>
        </div>
        <div class="footer row">
            Site for Foundations of Data Science coursework. University of Southampton, 2016.
        </div>
    </form>
</body>
</html>

