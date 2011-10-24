package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import parsers.yaml.YAML;
	
	public class as3YAMLTest extends Sprite
	{
		public function as3YAMLTest()
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, on_complete);
			loader.load(new URLRequest('examples/config.yml'));
		}
		
		private function on_complete(evt:Event):void{
			var loader:URLLoader = evt.target as URLLoader;
						
			var y:YAML = new YAML();
			
			log(y.eval(loader.data as String));
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