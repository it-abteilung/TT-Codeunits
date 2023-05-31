Codeunit 50005 TBarcode
{

    //     trigger OnRun()
    //     begin
    //     end;


    //     procedure BarcodeEAN128FileSystem(var _TempBlob: Record TempBlob;_BarcodeData: Text)
    //     var
    //         barcode: dotnet Barcode;
    //         imageType: dotnet ImageType;
    //         fileMgt: Codeunit "File Management";
    //         serverFileName: Text;
    //     begin
    //         //FNC1 = \F
    //         barcode := barcode.Barcode;
    //         barcodeEAN128(barcode, _BarcodeData);

    //         //Temporäre Datei anlegen
    //         serverFileName := fileMgt.ServerTempFileName('.bmp');

    //         //Barcode in Datei schreiben
    //         barcode.Draw(serverFileName, imageType.Bmp);

    //         //Datei in Tabelle importieren
    //         fileMgt.BLOBImportFromServerFile(_TempBlob, serverFileName);
    //         fileMgt.DeleteServerFile(serverFileName);
    //     end;


    //     procedure BarcodeEAN128MemoryStream(var _TempBlob: Record TempBlob;_BarcodeData: Text)
    //     var
    //         barcode: dotnet Barcode;
    //         bitmap: dotnet Bitmap;
    //         memoryStream: dotnet MemoryStream;
    //         outStr: OutStream;
    //         imageFormat: dotnet ImageFormat;
    //     begin
    //         //FNC1 = \F
    //         barcode := barcode.Barcode;
    //         barcodeEAN128(barcode, _BarcodeData);

    //         //Barcode in MemoryStream speichern
    //         Clear(memoryStream);
    //         memoryStream := memoryStream.MemoryStream();
    //         bitmap := barcode.DrawBitmap();
    //         bitmap.Save(memoryStream, imageFormat.Bmp);
    //         memoryStream.Position := 0;

    //         //Barcode aus MemoryStream laden
    //         Clear(_TempBlob.Blob);
    //         _TempBlob.Blob.CreateOutstream(outStr);
    //         memoryStream.WriteTo(outStr);
    //     end;

    //     local procedure barcodeEAN128(var _Barcode: dotnet Barcode;_BarcodeData: Text)
    //     var
    //         barcodeType: dotnet BarcodeType;
    //         licenseType: dotnet LicenseType;
    //         productID: dotnet TBarCodeProduct;
    //         optimalSize: dotnet Size;
    //         graphics: dotnet Graphics;
    //         rectangle: dotnet Rectangle;
    //         tBarcodeSetup: Record "TBarcode - Setup";
    //     begin
    //         //Barcode lizenzieren
    //         tBarcodeSetup.Get;
    //         _Barcode.License(tBarcodeSetup.Licensee, licenseType.DeveloperOrWeb(),tBarcodeSetup."Number of Licenses",tBarcodeSetup.GetLicenseKey(),productID.Barcode2D());

    //         //Barcode Properties setzen
    //         _Barcode.BarcodeType := barcodeType.EanUcc128();
    //         _Barcode.Data := _BarcodeData;
    //         _Barcode.TranslateEscapeSequences(true);
    //         _Barcode.Dpi := 200;

    //         optimalSize := _Barcode.CalculateOptimalBitmapSize(graphics, 4, 2);

    //         _Barcode.BoundingRectangle := rectangle.Rectangle(0,0,optimalSize.Width, optimalSize.Height);
    //         _Barcode.FontHeight(64);
    //     end;


    //     procedure BarcodeDataMatrixFileSystem(var _TempBlob: Record TempBlob;_BarcodeData: Text)
    //     var
    //         barcode: dotnet Barcode;
    //         imageType: dotnet ImageType;
    //         fileMgt: Codeunit "File Management";
    //         serverFileName: Text;
    //     begin
    //         //FNC1 = \F
    //         barcode := barcode.Barcode;
    //         barcodeDataMatrix(barcode, _BarcodeData);

    //         //Temporäre Datei anlegen
    //         serverFileName := fileMgt.ServerTempFileName('.bmp');

    //         //Barcode in Datei schreiben
    //         barcode.Draw(serverFileName, imageType.Bmp);

    //         //Datei in Tabelle importieren
    //         fileMgt.BLOBImportFromServerFile(_TempBlob, serverFileName);
    //         fileMgt.DeleteServerFile(serverFileName);
    //     end;


    //     procedure BarcodeDataMatrixMemoryStream(var _TempBlob: Record TempBlob;_BarcodeData: Text)
    //     var
    //         barcode: dotnet Barcode;
    //         bitmap: dotnet Bitmap;
    //         memoryStream: dotnet MemoryStream;
    //         outStr: OutStream;
    //         imageFormat: dotnet ImageFormat;
    //     begin
    //         //FNC1 = \F
    //         barcode := barcode.Barcode;
    //         barcodeDataMatrix(barcode, _BarcodeData);

    //         //Barcode in MemoryStream speichern
    //         Clear(memoryStream);
    //         memoryStream := memoryStream.MemoryStream();
    //         bitmap := barcode.DrawBitmap();
    //         bitmap.Save(memoryStream, imageFormat.Bmp);
    //         memoryStream.Position := 0;

    //         //Barcode aus MemoryStream laden
    //         Clear(_TempBlob.Blob);
    //         _TempBlob.Blob.CreateOutstream(outStr);
    //         memoryStream.WriteTo(outStr);
    //     end;

    //     local procedure barcodeDataMatrix(var _Barcode: dotnet Barcode;_BarcodeData: Text)
    //     var
    //         barcodeType: dotnet BarcodeType;
    //         licenseType: dotnet LicenseType;
    //         productID: dotnet TBarCodeProduct;
    //         optimalSize: dotnet Size;
    //         graphics: dotnet Graphics;
    //         rectangle: dotnet Rectangle;
    //         tBarcodeSetup: Record "TBarcode - Setup";
    //     begin
    //         //Barcode lizenzieren
    //         tBarcodeSetup.Get;
    //         _Barcode.License(tBarcodeSetup.Licensee, licenseType.DeveloperOrWeb(),tBarcodeSetup."Number of Licenses",tBarcodeSetup.GetLicenseKey(),productID.Barcode2D());

    //         //Barcode Properties setzen
    //         _Barcode.BarcodeType := barcodeType.DataMatrix();
    //         _Barcode.Data := _BarcodeData;
    //         _Barcode.TranslateEscapeSequences(true);
    //         _Barcode.Dpi := 200;

    //         optimalSize := _Barcode.CalculateOptimalBitmapSize(graphics, 4, 2);

    //         _Barcode.BoundingRectangle := rectangle.Rectangle(0,0,optimalSize.Width, optimalSize.Height);
    //         _Barcode.FontHeight(64);
    //     end;
}

