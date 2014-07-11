package de.axelspringer.videoplayer.controller
{
    public interface IVideoController
    {
        function loadURL(url:String):void;
        function volume(value:Number = NaN):Number;

    }
}
