package parsers.yaml
{
	/**
	 * Actionscript 3.0 port of the CommonJS YAML Parser (https://github.com/visionmedia/js-yaml)
	 *  
	 * @author gillesv
	 * 
	 */	
	public class YAML
	{
		/**
		 * YAML grammar tokens.
		 */
		
		private const tokens:Array = [
			['comment', /^#[^\n]*/],
			['indent', /^\n( *)/],
			['space', /^ +/],
			['true', /^\b(enabled|true|yes|on)\b/],
			['false', /^\b(disabled|false|no|off)\b/],
			['null', /^\b(null|Null|NULL|~)\b/],
			['string', /^"(.*?)"/],
			['string', /^'(.*?)'/],
			['timestamp', /^((\d{4})-(\d\d?)-(\d\d?)(?:(?:[ \t]+)(\d\d?):(\d\d)(?::(\d\d))?)?)/],
			['float', /^(\d+\.\d+)/],
			['int', /^(\d+)/],
			['doc', /^---/],
			[',', /^,/],
			['{', /^\{(?![^\n\}]*\}[^\n]*[^\s\n\}])/],
			['}', /^\}/],
			['[', /^\[(?![^\n\]]*\][^\n]*[^\s\n\]])/],
			[']', /^\]/],
			['-', /^\-/],
			[':', /^[:]/],
			['string', /^(?![^:\n\s]*:[^\/]{2})(([^:,\]\}\n\s]|(?!\n)\s(?!\s*?\n)|:\/\/|,(?=[^\n]*\s*[^\]\}\s\n]\s*\n)|[\]\}](?=[^\n]*\s*[^\]\}\s\n]\s*\n))*)(?=[,:\]\}\s\n]|$)/], 
			['id', /^([\w][\w -]*)/]
		];
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function YAML(){
			
		}
		
		public function eval(value:String):*{
			trace(tokenize(value));
			
			return new Parser(tokenize(value)).parse();
		}
		
		private function context(str:*):String {
			if (typeof str !== 'string') return '';
			
			str = str.slice(0, 25).replace(/\n/g, '\\n').replace(/"/g, '\\\"');
			
			return 'near "' + str + '"';
		}
		
		/**
		 * Tokenize the given _str_.
		 *
		 * @param  {string} str
		 * @return {array}
		 * @api private
		 */
		private function tokenize(str:String):Array{
			var token:Array, captures:*, ignore:Boolean, input:*,
				indents:int = 0, lastIndents:int = 0,
				stack:Array = [], indentAmount:int = -1;
			
			while (str.length) {
				for (var i:int = 0, len:int = tokens.length; i < len; ++i){
					if ((captures = tokens[i][1].exec(str)) != null) {
						
						token = [tokens[i][0], captures]; 
						str = str.replace(tokens[i][1], '');
						
						switch (token[0]) {
							case 'comment':
								ignore = true;
								break
							case 'indent':
								lastIndents = indents;
								
								// determine the indentation amount from the first indent
								if (indentAmount == -1) {
									indentAmount = token[1][1].length;
								}
								
								indents = token[1][1].length / indentAmount;
								
								if (indents === lastIndents){
									ignore = true;
								}else if (indents > lastIndents + 1){
									throw new Error('invalid indentation, got ' + indents + ' instead of ' + (lastIndents + 1));
								}else if (indents < lastIndents) {
									input = token[1].input;
									token = ['dedent', input];	// @gillesv: note for later
									//token.input = input;
									
									while (--lastIndents > indents){
										stack.push(token);
									}
								}
								break;
						}
					}
				}
				
				if (!ignore){
					if (token){
						stack.push(token);
						token = null;
					}else{ 
						throw new Error(context(str));
					}
					
					ignore = false;
				}
			}
				
			return stack;
		}
	}
}
internal class Parser{
	
	public var tokens:Array;
	
	function Parser(tokens:Array){
		this.tokens = tokens;
	}
		
	/**
	 * Look-ahead a single token.
	 */	
	public function peek():* {
		return tokens[0];
	}
	
	/**
	 * Return the next token type. 
	 */	
	public function peekType(val:*):Boolean{
		return tokens[0] && tokens[0][0] === val;
	}
	
	/**
	 * Advance by a single token.
	 */
	public function advance():*{
		return tokens.shift();
	}
	
	/**
	 * Advance and return the token's value. 
	 */	
	public function advanceValue():*{
		return this.advance()[1][1];
	}
	
	/**
	 * Accept _type_ and advance or do nothing. 
	 */	
	public function accept(type:*):*{
		if(peekType(type))
			return this.advance();
		
		return null;
	}
	
	/**
	 * Expect _type_ or throw an error _msg_.
	 */	
	public function expect(type:*, msg:*):void{
		if (accept(type)) return;
		
		throw new Error(msg + ', ' + this.peek()[2]);	// this.peek()[1].input
	}
	
	/**
	 * Ignore space & advance
	 */	
	public function ignoreSpace():void{
		while(peekType('space')){
			advance();
		}
	}
	
	/**
	 * Ignore whitespace & continue 
	 */	
	public function ignoreWhitespace():void{
		while(peekType('space') || peekType('indent') || peekType('dedent')){
			advance();
		}
	}
	
	/*** parsing methods ***/
	
	public function parseDoc():* {
		accept('doc');
		expect('indent', 'expected indent after document');
		
		var val:* = this.parse();
		
		expect('dedent', 'document not properly dedented');
		
		return val;
	}
	
	public function parseList():Array {
		var list:Array = [];
		
		while (accept('-')) {
			ignoreSpace();
			
			if (accept('indent')){
				list.push(parse());
				expect('dedent', 'list item not properly dedented');
			}else{
				list.push(parse());
			}
			
			this.ignoreSpace();
		}
		
		return list;
	}
	
	public function parseInlineList():* {
		var list:Array = [], i:int = 0;
		
		accept('[');
		
		while (!accept(']')) {
			ignoreSpace();
			
			if (i) expect(',', 'expected comma');
			
			ignoreSpace();
			list.push(parse());
			ignoreSpace();
			
			++i;
		}
		return list;
	}
	
	 public function parseTimestamp():Date {
		var token:Array = this.advance()[1];
		var date:Date = new Date();
		var year:* = token[2]
			, month:* = token[3]
			, day:* = token[4]
			, hour:* = token[5] || 0 
			, min:* = token[6] || 0
			, sec:* = token[7] || 0;
		
		date.setUTCFullYear(year, month-1, day);
		date.setUTCHours(hour);
		date.setUTCMinutes(min);
		date.setUTCSeconds(sec);
		date.setUTCMilliseconds(0);
		
		return date;
	}
	
	public function parseHash():* {
		var id:*, hash:Object = {};
		
		while (peekType('id') && (id = advanceValue())) {
			
			expect(':', 'expected semi-colon after id');
			ignoreSpace();
			
			if (accept('indent')){
				hash[id] = parse();
				expect('dedent', 'hash not properly dedented');
			}else{
				hash[id] = parse();
			}
			
			ignoreSpace();
		}
		
		return hash;
	}
	
	 public function parseInlineHash():* {
		var hash:Object = {}, id:*, i:int = 0;
		
		accept('{');
		
		while (!accept('}')) {
			ignoreSpace();
			
			if (i){ 
				expect(',', 'expected comma');
			}
			
			this.ignoreWhitespace();
			
			if (peekType('id') && (id = advanceValue())) {
				expect(':', 'expected semi-colon after id');
				ignoreSpace();
				hash[id] = parse();
				ignoreWhitespace()
			}
			
			++i;
		}
		return hash
	}
	
	public function parse():*{
		switch(peek()[0]){
			case 'doc':
				return this.parseDoc();
			case '-':
				return this.parseList();
			case '{':
				return this.parseInlineHash();
			case '[':
				return this.parseInlineList();
			case 'id':
				return this.parseHash();
			case 'string':
				return this.advanceValue();
			case 'timestamp':
				return this.parseTimestamp();
			case 'float':
				return parseFloat(this.advanceValue());
			case 'int':
				return parseInt(this.advanceValue());
			case 'true':
				this.advanceValue(); return true;
			case 'false':
				this.advanceValue(); return false;
			case 'null':
				this.advanceValue(); return null;
		}
		
		return null;
	}
}