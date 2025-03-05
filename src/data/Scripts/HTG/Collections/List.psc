ScriptName HTG:Collections:List Extends ObjectReference

;-- Variables ---------------------------------------
Int _count = 0
Var[] _internalArray
Bool _isInitialized
Int _maxSize = 128 Const

;-- Guards ------------------------------------------
;*** WARNING: Guard declaration syntax is EXPERIMENTAL, subject to change
Guard _arrayGuard

;-- Properties --------------------------------------
String Property ArrayType = "Var" Auto hidden
Int Property Count hidden
  Int Function Get()
    Return _count ; #DEBUG_LINE_NO:10
  EndFunction
EndProperty
Var[] Property _Array hidden
  Var[] Function Get()
    Return _internalArray ; #DEBUG_LINE_NO:16
  EndFunction
EndProperty
Bool Property IsInitialized hidden
  Bool Function Get()
    Return _isInitialized ; #DEBUG_LINE_NO:22
  EndFunction
EndProperty

;-- Functions ---------------------------------------

HTG:Collections:List Function List(Int aiSize) Global
  HTG:Collections:List res = HTG:Collections:List._CreateReference(HTG:Collections:List._CreateForm(2071, "HTG-Regenesys-Core"), aiSize) as HTG:Collections:List ; #DEBUG_LINE_NO:33
  res.Enable(False) ; #DEBUG_LINE_NO:34
  res.Initialize(aiSize) ; #DEBUG_LINE_NO:35
EndFunction

Form Function _CreateForm(Int aiFormId, String modName) Global
  Form aForm = Game.GetFormFromFile(aiFormId, modName + ".esp") ; #DEBUG_LINE_NO:39
  htg:systemlogger.LogObjectGlobal(aForm as ScriptObject, ("HTG:Collections:List._CreateForm(" + aiFormId as String) + ", " + modName + ".esp): " + aForm as String) ; #DEBUG_LINE_NO:40
  If aForm == None ; #DEBUG_LINE_NO:41
    aForm = Game.GetFormFromFile(aiFormId, modName + ".esm") ; #DEBUG_LINE_NO:42
    htg:systemlogger.LogObjectGlobal(aForm as ScriptObject, ("HTG:Collections:List._CreateForm(" + aiFormId as String) + ", " + modName + ".esm): " + aForm as String) ; #DEBUG_LINE_NO:43
  EndIf
  Return aForm ; #DEBUG_LINE_NO:46
EndFunction

ObjectReference Function _CreateReference(Form akForm, Int aiSize) Global
  If akForm != None ; #DEBUG_LINE_NO:50
    ObjectReference ref = Game.GetPlayer().PlaceAtMe(akForm, 1, False, True, False, None, None, True) ; #DEBUG_LINE_NO:51
    htg:systemlogger.LogObjectGlobal(ref as ScriptObject, (("HTG:Collections:List._CreateReference(" + akForm as String) + ", " + aiSize as String) + "): " + ref as String) ; #DEBUG_LINE_NO:52
    Return ref ; #DEBUG_LINE_NO:53
  EndIf
  Return None ; #DEBUG_LINE_NO:56
EndFunction

Bool Function Initialize(Int aiSize)
  If _isInitialized ; #DEBUG_LINE_NO:60
    Return False ; #DEBUG_LINE_NO:61
  EndIf
  Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:64
    _internalArray = new Var[aiSize] ; #DEBUG_LINE_NO:65
    _isInitialized = True ; #DEBUG_LINE_NO:66
  EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
  Return True ; #DEBUG_LINE_NO:69
EndFunction

Function Clear()
  If !_isInitialized ; #DEBUG_LINE_NO:73
    Return  ; #DEBUG_LINE_NO:74
  EndIf
  Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:77
    _internalArray.clear() ; #DEBUG_LINE_NO:78
    _count = 0 ; #DEBUG_LINE_NO:79
    _isInitialized = False ; #DEBUG_LINE_NO:80
  EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
EndFunction

Var Function GetVarAt(Int index)
  Return _internalArray[index] ; #DEBUG_LINE_NO:85
EndFunction

Int Function Add(Var akItem, Bool overrideExisting)
  If !_isInitialized || !Self.TestType(akItem) ; #DEBUG_LINE_NO:89
    Return -1 ; #DEBUG_LINE_NO:90
  EndIf
  Int fI = Self.Find(akItem) ; #DEBUG_LINE_NO:93
  If !overrideExisting && fI > -1 ; #DEBUG_LINE_NO:94
    Return fI ; #DEBUG_LINE_NO:95
  EndIf
  Int I = -1 ; #DEBUG_LINE_NO:98
  Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:99
    I = Self.FindFirstEmpty() ; #DEBUG_LINE_NO:100
    If I > -1 ; #DEBUG_LINE_NO:101
      _internalArray[I] = akItem ; #DEBUG_LINE_NO:102
      _count += 1 ; #DEBUG_LINE_NO:103
    EndIf
    If _internalArray.Length < _maxSize ; #DEBUG_LINE_NO:106
      _internalArray.add(akItem, 1) ; #DEBUG_LINE_NO:107
      _count += 1 ; #DEBUG_LINE_NO:108
      I = _internalArray.Length ; #DEBUG_LINE_NO:109
    EndIf
  EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
  htg:systemlogger.LogObjectGlobal(akItem as ScriptObject, ("Added item with Index: " + I as String) + " and Count: " + _count as String) ; #DEBUG_LINE_NO:113
  Return I ; #DEBUG_LINE_NO:114
EndFunction

Int Function Remove(Var akItem)
  If !_isInitialized || !Self.TestType(akItem) ; #DEBUG_LINE_NO:118
    Return -1 ; #DEBUG_LINE_NO:119
  EndIf
  Int I = -1 ; #DEBUG_LINE_NO:122
  Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:123
    I = Self.Find(akItem) ; #DEBUG_LINE_NO:124
    If I > -1 ; #DEBUG_LINE_NO:125
      _internalArray.remove(I, 1) ; #DEBUG_LINE_NO:126
      _count -= 1 ; #DEBUG_LINE_NO:127
    EndIf
  EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
  htg:systemlogger.LogObjectGlobal(akItem as ScriptObject, ("Removed item with Index: " + I as String) + " and Count: " + _count as String) ; #DEBUG_LINE_NO:131
  Return I ; #DEBUG_LINE_NO:132
EndFunction

Int Function Find(Var akItem)
  If !_isInitialized || !Self.TestType(akItem) ; #DEBUG_LINE_NO:136
    Return -1 ; #DEBUG_LINE_NO:137
  EndIf
  Int I = 0 ; #DEBUG_LINE_NO:140
  While I < _internalArray.Length ; #DEBUG_LINE_NO:141
    If Self.CompareItems(_internalArray[I], akItem) ; #DEBUG_LINE_NO:142
      Return I ; #DEBUG_LINE_NO:143
    EndIf
    I += 1 ; #DEBUG_LINE_NO:145
  EndWhile
  Return -1 ; #DEBUG_LINE_NO:148
EndFunction

Int[] Function FindAll(Var akItem)
  Int I = 0 ; #DEBUG_LINE_NO:152
  Int[] resArray = new Int[0] ; #DEBUG_LINE_NO:153
  While I < Self.Count ; #DEBUG_LINE_NO:155
    If !Self.IsNone(_internalArray[I]) ; #DEBUG_LINE_NO:156
      If Self.CompareItems(_internalArray[I], akItem) ; #DEBUG_LINE_NO:157
        resArray.add(I, 1) ; #DEBUG_LINE_NO:158
      EndIf
    EndIf
    I += 1 ; #DEBUG_LINE_NO:162
  EndWhile
  If resArray.Length > 0 ; #DEBUG_LINE_NO:165
    htg:intutility.IntArrayClean(resArray) ; #DEBUG_LINE_NO:166
  EndIf
  Return resArray ; #DEBUG_LINE_NO:169
EndFunction

Bool Function Contains(Var akItem)
  If Self.Find(akItem) > -1 ; #DEBUG_LINE_NO:173
    Return True ; #DEBUG_LINE_NO:174
  EndIf
  Return False ; #DEBUG_LINE_NO:177
EndFunction

Int Function FindFirstEmpty()
  Int I = 0 ; #DEBUG_LINE_NO:181
  While I < _internalArray.Length ; #DEBUG_LINE_NO:182
    If Self.IsNone(_internalArray[I]) ; #DEBUG_LINE_NO:183
      Return I ; #DEBUG_LINE_NO:184
    EndIf
    I += 1 ; #DEBUG_LINE_NO:187
  EndWhile
  Return -1 ; #DEBUG_LINE_NO:190
EndFunction

Bool Function Sort(Int aiStartingIndex)
  Bool bFirstNoneFound = False ; #DEBUG_LINE_NO:194
  Int iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:195
  While aiStartingIndex < _internalArray.Length ; #DEBUG_LINE_NO:196
    If Self.IsNone(_internalArray[aiStartingIndex]) ; #DEBUG_LINE_NO:197
      If bFirstNoneFound == False ; #DEBUG_LINE_NO:198
        bFirstNoneFound = True ; #DEBUG_LINE_NO:199
        iFirstNonePos = aiStartingIndex ; #DEBUG_LINE_NO:200
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:201
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:203
      EndIf
    ElseIf bFirstNoneFound == True ; #DEBUG_LINE_NO:206
      If !Self.IsNone(_internalArray[aiStartingIndex]) ; #DEBUG_LINE_NO:207
        Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:208
          _internalArray[iFirstNonePos] = _internalArray[aiStartingIndex] ; #DEBUG_LINE_NO:209
          _internalArray[aiStartingIndex] = None ; #DEBUG_LINE_NO:210
        EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
        Self.Sort(iFirstNonePos + 1) ; #DEBUG_LINE_NO:213
        Return True ; #DEBUG_LINE_NO:214
      Else
        aiStartingIndex += 1 ; #DEBUG_LINE_NO:216
      EndIf
    Else
      aiStartingIndex += 1 ; #DEBUG_LINE_NO:219
    EndIf
  EndWhile
  Return False ; #DEBUG_LINE_NO:224
EndFunction

Function Clean()
  Int I = 0 ; #DEBUG_LINE_NO:247
  Guard _arrayGuard ;*** WARNING: Experimental syntax, may be incorrect: Guard  ; #DEBUG_LINE_NO:250
    While I < _internalArray.Length ; #DEBUG_LINE_NO:251
      If Self.IsNone(_internalArray[I]) ; #DEBUG_LINE_NO:252
        _internalArray.remove(I, 1) ; #DEBUG_LINE_NO:253
      EndIf
    EndWhile
  EndGuard ;*** WARNING: Experimental syntax, may be incorrect: EndGuard 
  Self.Sort(0) ; #DEBUG_LINE_NO:258
EndFunction

Bool Function IsNone(Var akItem)
  Return False ; #DEBUG_LINE_NO:262
EndFunction

Bool Function TestType(Var akItem)
  If _internalArray.Length == 0 ; #DEBUG_LINE_NO:266
    Return True ; #DEBUG_LINE_NO:267
  EndIf
  Var kArrayItem = _internalArray[0] ; #DEBUG_LINE_NO:270
  If kArrayItem as Bool && akItem as Bool ; #DEBUG_LINE_NO:271
    Return True ; #DEBUG_LINE_NO:272
  ElseIf (kArrayItem as Int) as Bool && (akItem as Int) as Bool ; #DEBUG_LINE_NO:273
    Return True ; #DEBUG_LINE_NO:274
  ElseIf (kArrayItem as Float) as Bool && (akItem as Float) as Bool ; #DEBUG_LINE_NO:275
    Return True ; #DEBUG_LINE_NO:276
  ElseIf (kArrayItem as ScriptObject) as Bool && (akItem as ScriptObject) as Bool ; #DEBUG_LINE_NO:280
    Return True ; #DEBUG_LINE_NO:281
  EndIf
  Return False ; #DEBUG_LINE_NO:284
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
  If !Self.IsNone(akArrayItem) && !Self.IsNone(akItem) ; #DEBUG_LINE_NO:288
    If akArrayItem is Bool && akItem is Bool ; #DEBUG_LINE_NO:289
      Return akArrayItem as Bool == akItem as Bool ; #DEBUG_LINE_NO:290
    ElseIf akArrayItem is Int && akItem is Int ; #DEBUG_LINE_NO:291
      Return akArrayItem as Int == akItem as Int ; #DEBUG_LINE_NO:292
    ElseIf akArrayItem is Float && akItem is Float ; #DEBUG_LINE_NO:293
      Return akArrayItem as Float == akItem as Float ; #DEBUG_LINE_NO:294
    ElseIf akArrayItem is ScriptObject && akItem is ScriptObject ; #DEBUG_LINE_NO:298
      Return akArrayItem as ScriptObject == akItem as ScriptObject ; #DEBUG_LINE_NO:299
    EndIf
  EndIf
EndFunction

Var[] Function GetArray()
  Return _internalArray ; #DEBUG_LINE_NO:305
EndFunction

String Function ToString()
  String res = (("HTG:Collection:List:" + Self.GetFormID() as String) + "\n" + "\tHTG:Collection:List<" + ArrayType + ">\n" + "\tHTG:Collection:List.Count:" + _count as String) + "\n" + "\tHTG:Collection:List.Array:" + _internalArray as String ; #DEBUG_LINE_NO:309,310,311,312
  Return res ; #DEBUG_LINE_NO:314
EndFunction

Function WaitForInitialized()
  If Self.IsInitialized ; #DEBUG_LINE_NO:318
    Return  ; #DEBUG_LINE_NO:319
  EndIf
  Int currentCycle = 0 ; #DEBUG_LINE_NO:322
  Int maxCycle = 50 ; #DEBUG_LINE_NO:323
  Bool maxCycleHit = False ; #DEBUG_LINE_NO:324
  While !maxCycleHit && !Self.IsInitialized ; #DEBUG_LINE_NO:325
    Utility.Wait(0.100000001) ; #DEBUG_LINE_NO:326
    If currentCycle < maxCycle ; #DEBUG_LINE_NO:328
      currentCycle += 1 ; #DEBUG_LINE_NO:329
    Else
      maxCycleHit = True ; #DEBUG_LINE_NO:331
    EndIf
  EndWhile
EndFunction
