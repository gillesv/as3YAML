package parsers.yaml
{
	import be.proximity.framework.logging.Logr;

	/**
	 * Actionscript 3.0 port of the CommonJS YAML Parser (https://github.com/visionmedia/js-yaml)
	 *  
	 * @author gillesv
	 * 
	 */	
	public dynamic class YAML extends Object
	{
		private var string:String;
		
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
			// this regular expression needs revising for Flash
			['string', /^(?![^:\n\s]*:[^\/]{2})(([^:,\]\}\n\s]|(?!\n)\s(?!\s*?\n)|:\/\/|,(?=[^\n]*\s*[^\]\}\s\n]\s*\n)|[\]\}](?=[^\n]*\s*[^\]\}\s\n]\s*\n))*)(?=[,:\]\}\s\n]|$)/], 
			['id', /^([\w][\w -]*)/]
		];
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function YAML(value:String = null){
			this.string = value;
			
			if(this.string != null){
				eval(this.string);
			}
		}
		
		public function eval(value:String):void{
			this.string = value;
						
			var parser:Parser = new Parser(tokenize(value));
			
			Logr.o(parser.parse(), 0);
		}
		
		/**
		 * Tokenize the given _str_.
		 *
		 * @param  {string} str
		 * @return {array}
		 * @api private
		 */
		
		private function tokenize(str:String):Array{
			var stack:Array = [];
			var captures:Array, token:Array;
			var ignore:Boolean= false;
			var indents:int = 0, lastIndents:int = 0, indentAmount:int = -1;
			var input:String;
			
			while(str.length > 0){
				// loop tokens
				for(var i:int = 0, len:int = tokens.length; i < len; i++){
					// found
					if((captures = RegExp(tokens[i][1]).exec(str)) != null && captures.join('').length > 0){
						token = [tokens[i][0], captures];
						str = str.replace(tokens[i][1], '');
						
						switch(token[0]){
							case 'comment':
								ignore = true;
								
								break;
							case 'indent':
								lastIndents = indents;
								
								// determine indentation from the first indent
								if(indentAmount == -1){
									indentAmount = token[1][1].length;
								}
								
								indents = token[1][1].length / indentAmount;
								
								if(indents == lastIndents){
									ignore = true;
								}else if(indents > lastIndents + 1){
									throw new SyntaxError('invalid indentation, got ' + indents + ' instead of ' + (lastIndents + 1));
								}else if(indents < lastIndents){
									input = token[1].input;
									token = ['dedent'];
									token.input = input;
									
									while(--lastIndents > indents){
										stack.push(token);
									}
								}	
								
								break;
						}
						
						if(!ignore){
							if(token != null){
								stack.push(token);
							}else{
								// isn't a comment, but still no token
								throw new SyntaxError(context(str));
							}
						}
						
						token = null;
						ignore = false;
					}
				}
			}
			
			return stack;
			
			
			/*
			var token;
			var captures;
			var ignore;
			var input;
			var indents;
			var lastIndents;
			var stack = [];
			var indentAmount:int = -1;
			
			indents = lastIndents = 0;
			
			while (str.length) {
				for (var i = 0, len = tokens.length; i < len; ++i)
					if (captures = tokens[i][1].exec(str)) {
						token = [tokens[i][0], captures],
							str = str.replace(tokens[i][1], '')
						switch (token[0]) {
							case 'comment':
								ignore = true;
								break
							case 'indent':
								lastIndents = indents 
								// determine the indentation amount from the first indent
								if (indentAmount == -1) {
									indentAmount = token[1][1].length
								}
								
								indents = token[1][1].length / indentAmount
								
								if (indents === lastIndents){
									ignore = true
								}else if (indents > lastIndents + 1){
									throw new Error('invalid indentation, got ' + indents + ' instead of ' + (lastIndents + 1))
								}else if (indents < lastIndents) {
									input = token[1].input
									token = ['dedent']
									token.input = input
									while (--lastIndents > indents)
										stack.push(token)
								}else{
									trace("someone done messed");
								}
								
								break;
						}
						
					}
				if (!ignore)
					if (token)
						stack.push(token),
							token = null
					else 
						throw new Error(context(str))
				ignore = false
			}
			return stack
			*/
		}
	}
}
import be.proximity.framework.logging.Logr;

internal function context(str:*):String {
	if (typeof str !== 'string') return '';
	
	str = str.slice(0, 25).replace(/\n/g, '\\n').replace(/"/g, '\\\"');
	
	return 'near "' + str + '"';
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
		return this.tokens[0];
	}
	
	/**
	 * Return the next token type. 
	 */	
	public function peekType(val:*):Boolean{
		return this.tokens[0] &&
			this.tokens[0][0] === val
	}
	
	/**
	 * Advance by a single token.
	 */
	public function advance():*{
		return this.tokens.shift()
	}
	
	/**
	 * Advance and return the token's value. 
	 */	
	public function advanceValue():*{
		return this.advance()[1][1]
	}
	
	/**
	 * Accept _type_ and advance or do nothing. 
	 */	
	public function accept(type:*):*{
		if (this.peekType(type))
			return this.advance()
	}
	
	/**
	 * Expect _type_ or throw an error _msg_.
	 */	
	public function expect(type:*, msg:*):void{
		if (this.accept(type)) return
			throw new Error(msg + ', ' + context(this.peek()[1].input))
	}
	
	/**
	 * Ignore space & advance
	 */	
	public function ignoreSpace():void{
		while (this.peekType('space'))
			this.advance()
	}
	
	/**
	 * Ignore whitespace & continue 
	 */	
	public function ignoreWhitespace():void{
		while (this.peekType('space') ||
			this.peekType('indent') ||
			this.peekType('dedent'))
			this.advance()
	}
	
	/*** parsing methods ***/
	
	public function parseDoc():* {
		this.accept('doc')
		this.expect('indent', 'expected indent after document')
		var val = this.parse()			
		this.expect('dedent', 'document not properly dedented')
		return val
	}
	
	public function parseList():Array {
		var list = []
		while (this.accept('-')) {
			this.ignoreSpace()
			if (this.accept('indent'))
				list.push(this.parse()),
					this.expect('dedent', 'list item not properly dedented')
			else
				list.push(this.parse())
			this.ignoreSpace()
		}
		return list
	}
	
	public function parseInlineList():* {
		var list = [], i = 0
		this.accept('[')
		while (!this.accept(']')) {
			this.ignoreSpace()
			if (i) this.expect(',', 'expected comma')
			this.ignoreSpace()
			list.push(this.parse())
			this.ignoreSpace()
				++i
		}
		return list
	}
	
	 public function parseTimestamp():Date {
		 var token = this.advance()[1]
		 var date = new Date
		 var year = token[2]
			 , month = token[3]
			 , day = token[4]
			 , hour = token[5] || 0 
			 , min = token[6] || 0
			 , sec = token[7] || 0
		 
		 date.setUTCFullYear(year, month-1, day)
		 date.setUTCHours(hour)
		 date.setUTCMinutes(min)
		 date.setUTCSeconds(sec)
		 date.setUTCMilliseconds(0)
		 return date
	}
	
	public function parseHash():* {
		var id, hash = {}
		while (this.peekType('id') && (id = this.advanceValue())) {
			this.expect(':', 'expected semi-colon after id')
			this.ignoreSpace()
			if (this.accept('indent'))
				hash[id] = this.parse(),
					this.expect('dedent', 'hash not properly dedented')
			else
				hash[id] = this.parse()
			this.ignoreSpace()
		}
		return hash
	}
	
	 public function parseInlineHash():* {
		 var hash = {}, id, i = 0
		 this.accept('{')
		 while (!this.accept('}')) {
			 this.ignoreSpace()
			 if (i) this.expect(',', 'expected comma')
			 this.ignoreWhitespace()
			 if (this.peekType('id') && (id = this.advanceValue())) {
				 this.expect(':', 'expected semi-colon after id')
				 this.ignoreSpace()
				 hash[id] = this.parse()
				 this.ignoreWhitespace()
			 }
			 ++i
		 }
		 return hash
	}
	
	public function parse():*{		
		switch (this.peek()[0]) {
			case 'doc':
				return this.parseDoc()
			case '-':
				return this.parseList()
			case '{':
				return this.parseInlineHash()
			case '[':
				return this.parseInlineList()
			case 'id':
				return this.parseHash()
			case 'string':
				return this.advanceValue()
			case 'timestamp':
				return this.parseTimestamp()
			case 'float':
				return parseFloat(this.advanceValue())
			case 'int':
				return parseInt(this.advanceValue())
			case 'true':
				this.advanceValue(); return true
			case 'false':
				this.advanceValue(); return false
			case 'null':
				this.advanceValue(); return null
		}
	}
}