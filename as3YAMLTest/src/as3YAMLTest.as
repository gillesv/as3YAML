package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import parsers.yaml.YAML;
	
	public class as3YAMLTest extends Sprite
	{
		public function as3YAMLTest()
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(evt:Event):void{
				var string:String = loader.data as String;
								
				var yaml:YAML = new YAML(string);
			});
			loader.addEventListener(Event.OPEN, function(evt:Event):void{
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(evt:HTTPStatusEvent):void{
				//log(evt.status);
			});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(evt:IOErrorEvent):void{
				log("couldn't load");
			});
			loader.addEventListener(ProgressEvent.PROGRESS, function(evt:ProgressEvent):void{
				//log("Load progress: " + evt.bytesLoaded + " " + evt.bytesTotal);
			});
			loader.load(new URLRequest('examples/config.yml'));
		}
		
		/**
		 *  Simple Javascript logging function
		 */		
		private function log(text:*):void{
			if(ExternalInterface.available){
				ExternalInterface.call("console.log", text);
			}
			
			trace(text);
		}
	}
}