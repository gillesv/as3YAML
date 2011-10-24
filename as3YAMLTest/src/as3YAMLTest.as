package
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	
	public class as3YAMLTest extends Sprite
	{
		public function as3YAMLTest()
		{
			
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