package de.axelspringer.videoplayer.controller
{
    public interface IVideoController
    {
        function loadURL(url:String):void;
        function play():void;
        function pause():void;
        function volume(value:Number = NaN):Number;
        function muted(value:String = ""):Boolean;
        function currentTime(value:Number = NaN):Number;
        function getDuration():Number;
        function getBufferTime():Number;
        function enableHD(value:String = ""):void;
        function destroy():void;
    }
}
