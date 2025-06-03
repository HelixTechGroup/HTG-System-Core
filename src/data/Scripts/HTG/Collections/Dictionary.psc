Scriptname HTG:Collections:Dictionary extends ObjectReference
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:IntUtility

String Property KeyType = "Var" Auto Hidden
String Property ValueType = "Var" Auto Hidden

Int Property Count Hidden
    Int Function Get()
        return _count
    EndFunction 
EndProperty

Var[] Property _Keys Hidden
    Var[] Function Get()
        return _keyArray
    EndFunction
EndProperty

Var[] Property _Values Hidden
    Var[] Function Get()
        return _ValueArray
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _arrayGuard ProtectsFunctionLogic
Var[] _keyArray
Var[] _valueArray
Bool _isInitialized
Int _count = 0
Int _trackedIndex = 0
Int _maxSize = 128 Const

Dictionary Function Dictionary(Int aiSize = 4) Global 
    Dictionary res = _CreateDictionary(aiSize = aiSize)
    LogObjectGlobal(res, "HTG:Collections:Dictionary.Dictionary(" + aiSize  + "): " + res)
    return res
EndFunction

Bool Function Initialize(Int aiSize = 0)
    If _isInitialized
        return False
    EndIf

    LockGuard _arrayGuard
        _keyArray = new Var[aiSize]
        _valueArray = new Var[aiSize]
        _trackedIndex = 0
        _count = 0
        _isInitialized = True
    EndLockGuard

    return True
EndFunction

Function Clear()
    If !_isInitialized
        return
    EndIf

    LockGuard _arrayGuard
        _keyArray.Clear()
        _valueArray.Clear()
        _count = 0
        _trackedIndex = 0
        _isInitialized = False
    EndLockGuard
EndFunction

Var Function GetKeyValue(Var akKey)
    Int i = Find(akKey)
    If i > -1
        return _valueArray[i]
    EndIf
EndFunction

Var[] Function GetAt(Int index)
    Var[] kArray = new Var[0]

    kArray.Add(_keyArray[index], 1)
    kArray.Add(_valueArray[index], 1)

    return kArray
EndFunction

Int Function Add(Var akKey, Var akValue, Bool overrideExisting = False)
    If !_isInitialized || !TestValue(akKey) || !TestValue(akValue)
        return -1
    EndIf

    Int fI = Find(akKey)
    If !overrideExisting && fI > -1
        return fI
    EndIf

    Int i = -1
    LockGuard _arrayGuard
    i = _trackedIndex ; FindFirstEmpty()
    If i >= 0 && _trackedIndex <= _keyArray.Length
        _keyArray[i] = akKey
        _valueArray[i] = akValue
        _trackedIndex += 1
        _count += 1
    Else
        If _keyArray.Length < _maxSize
            _keyArray.Add(akKey, 1)
            _valueArray.Add(akValue, 1)
            _trackedIndex += 1
            _count += 1
            ; i = _internalArray.Length - 1
        EndIf
    EndIf
    EndLockGuard

    ; Clean()
    LogObjectGlobal(akValue as ScriptObject, "Added item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddDictionary(Dictionary akDictionary)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akDictionary.Count
        Var[] kPair = akDictionary.GetAt(kI)
        If TestPair(kPair[0], kPair[1]) 
            Int fI = Find(kPair[0])
            If fI < 0
                LockGuard _arrayGuard
                i = _trackedIndex ; FindFirstEmpty()
                If i > -1 && _trackedIndex <= _keyArray.Length
                    _keyArray[i] = kPair[0]
                    _valueArray[i] = kPair[1]
                    _trackedIndex += 1
                    _count += 1
                Else
                    If _keyArray.Length < _maxSize
                        _keyArray.Add(kPair[0], 1)
                        _valueArray.Add(kPair[1], 1)
                        _trackedIndex += 1
                        _count += 1
                        ; i = _internalArray.Length - 1
                    EndIf
                EndIf
                EndLockGuard
            EndIf
        EndIf
    EndWhile

    ; Clean()
    LogObjectGlobal(akDictionary, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddArray(Var[] akKeyArray, Var[] akValueArray)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akKeyArray.Length
        Var kKey = akKeyArray[i]
        Var kValue = akValueArray[i]
        If TestKey(kKey) && TestValue(kValue)
            Int fI = Find(kKey)
            If fI < 0
                LockGuard _arrayGuard
                i = _trackedIndex ; FindFirstEmpty()
                If i > -1 && _trackedIndex <= _keyArray.Length
                    _keyArray[i] = kKey
                    _valueArray[i] = kValue
                    _trackedIndex += 1
                    _count += 1
                Else
                    If _keyArray.Length < _maxSize
                        _keyArray.Add(kKey, 1)
                        _valueArray.Add(kValue, 1)
                        _trackedIndex += 1
                        _count += 1
                        ; i = _internalArray.Length - 1
                    EndIf
                EndIf
                EndLockGuard
            EndIf
        EndIf
    EndWhile

    ; Clean()
    LogObjectGlobal(Self, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Remove(Var akKey)
    If !_isInitialized || !TestKey(akKey)
        return -1
    EndIf

    Int i = -1
    LockGuard _arrayGuard
        i = Find(akKey)
        If i > -1
            _keyArray.Remove(i)
            _valueArray.Remove(i)
            _trackedIndex -= 1
            _count -= 1
        EndIf
    EndLockGuard

    Sort()
    LogObjectGlobal(akKey as ScriptObject, "Removed item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Find(Var akKey)
    If !_isInitialized || !TestKey(akKey)
        return -1
    EndIf

    Int i = 0
    While i < _keyArray.Length
        If CompareType(_keyArray[i], akKey)
            return i
        EndIf
        i += 1
    EndWhile

    return -1
EndFunction

Bool Function Contains(Var akKey)
    If !IsNone(akKey) && Find(akKey) > -1
        return True
    EndIf

    return False
EndFunction

Int Function FindFirstEmpty()
    Int i = 0
    While i < _keyArray.Length
        If IsNone(_keyArray[i])
            return i
        EndIf

        i += 1
    EndWhile
    
    return -1
endFunction

Bool Function Sort(Int aiStartingIndex = 0)
    Bool bFirstNoneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < _keyArray.Length
        If IsNone(_keyArray[aiStartingIndex])
            If bFirstNoneFound == False
                bFirstNoneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstNoneFound == True
                If !IsNone(_keyArray[aiStartingIndex])
                    LockGuard _arrayGuard
                        _keyArray[iFirstNonePos] = _keyArray[aiStartingIndex]
                        _keyArray[aiStartingIndex] = None

                        _valueArray[iFirstNonePos] = _valueArray[aiStartingIndex]
                        _valueArray[aiStartingIndex] = None
                    EndLockGuard

                    Sort(iFirstNonePos + 1)
                    return True
                Else
                    aiStartingIndex += 1
                EndIf
            Else
                aiStartingIndex += 1
            EndIf
        EndIf
    EndWhile

    return False
EndFunction

Function Clean()
    Int i = 0
    ; Sort()

    LockGuard _arrayGuard
        While i < _keyArray.Length
            If IsNone(_keyArray[i])
                _keyArray.Remove(i)
                _valueArray.Remove(i)
            EndIf
        EndWhile
    EndLockGuard

    Sort()
EndFunction

Bool Function IsNone(Var akValue)
    If akValue is ScriptObject
        return HTG:UtilityExt.IsNone(akValue as ScriptObject) 
    EndIf

    return False
EndFunction

Bool Function TestPair(Var akKey, Var akValue)
    If _keyArray.Length == 0
        return True
    EndIf

    return TestKey(akKey) && TestValue(akValue)
EndFunction

Bool Function TestType(Var akType1, Var akType2)

EndFunction

Bool Function TestValue(Var akValue)
    If _valueArray.Length == 0
        return True
    EndIf

    Var kArrayItem = _valueArray[0]
    If kArrayItem as Bool && akValue as Bool
        return True
    ElseIf kArrayItem as Int && akValue as Int
        return True
    ElseIf kArrayItem as Float && akValue as Float
        return True
    ; ElseIf kArrayItem as Array && akValue as Array
    ;     return akArrayItem as Array == akValue as Array
    ; ElseIf kArrayItem as Struct
    ElseIf kArrayItem as ScriptObject && akValue as ScriptObject
        return True
    EndIf

    return False
EndFunction

Bool Function TestKey(Var akKey)
    If _keyArray.Length == 0
        return True
    EndIf

    Var kArrayItem = _keyArray[0]
    If kArrayItem as Bool && akKey as Bool
        return True
    ElseIf kArrayItem as Int && akKey as Int
        return True
    ElseIf kArrayItem as Float && akKey as Float
        return True
    ; ElseIf kArrayItem as Array && akKey as Array
    ;     return akArrayItem as Array == akKey as Array
    ; ElseIf kArrayItem as Struct
    ElseIf kArrayItem as ScriptObject && akKey as ScriptObject
        return True
    EndIf

    return False
EndFunction

Bool Function CompareType(Var akArrayItem, Var akItem)
    If !IsNone(akArrayItem) && !IsNone(akItem)
        If akArrayItem is Bool && akItem is Bool
            return akArrayItem as Bool == akItem as Bool
        ElseIf akArrayItem is Int && akItem is Int
            return akArrayItem as Int == akItem as Int
        ElseIf akArrayItem is Float && akItem is Float
            return akArrayItem as Float == akItem as Float
        ; ElseIf akArrayItem is Array && akItem is Array
        ;     return akArrayItem as Array == akItem as Array
        ; ElseIf akArrayItem is Struct
        ElseIf akArrayItem is ScriptObject && akItem is ScriptObject
            return akArrayItem as ScriptObject == akItem as ScriptObject
        EndIf
    EndIf
EndFunction

Var[] Function GetKeyArray()
    return _keyArray
EndFunction

Var[] Function GetValueArray()
    return _valueArray
EndFunction

String Function ToString()
    String res = "HTG:Collection:Dictionary:" + Self.GetFormID() + "\n" \
    + "\tHTG:Collection:Dictionary<" + KeyType + ", " + ValueType + ">\n" \
    + "\tHTG:Collection:Dictionary.Count:" + _count + "\n" \
    + "\tHTG:Collection:Dictionary.Keys:" + _keyArray

    return res
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 50
    Bool maxCycleHit
    While !maxCycleHit && !_isInitialized
        Utility.Wait(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isInitialized
EndFunction

Dictionary Function _CreateDictionary(Int aiFormId = 0x00000834, String asModName = "HTG-System-Core", Int aiSize = 4) Global
    Form kForm = HTG:FormUtility.CreateForm(aiFormId, asModName)
    Dictionary res = HTG:FormUtility.CreateReference(Game.GetPlayer(), kform) as Dictionary
    res.Enable(False)
    res.Initialize(aiSize)
    return res
EndFunction