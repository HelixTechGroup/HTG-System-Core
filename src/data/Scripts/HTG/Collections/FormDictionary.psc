Scriptname HTG:Collections:FormDictionary extends ObjectReference
{Form Keyed Dictionary Collection}
import HTG
import HTG:Structs
import HTG:SystemLogger
import HTG:IntUtility
import HTG:UtilityExt
import HTG:FormUtility

String Property KeyType = "Form" Auto Hidden
String Property ValueType = "Form" Auto Hidden

Int Property Count Hidden
    Int Function Get()
        return _count
    EndFunction
EndProperty

KeyValuePair[] Property _Array Hidden
    KeyValuePair[] Function Get()
        return _internalArray
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _arrayGuard ProtectsFunctionLogic
KeyValuePair[] _internalArray
Bool _isInitialized
Int _count = 0
Int _trackedIndex = 0
Int _maxSize = 128 Const

FormDictionary Function FormDictionary(SystemModuleInformation akMod, Int aiSize = 0) Global 
    FormDictionary res = _CreateDictionary(akMod, aiSize = aiSize)
    LogObjectGlobal(res, "HTG:Collections:FormDictionary.FormDictionary(" + aiSize  + "): " + res)
    return res
EndFunction

; FormDictionary Function FormDictionaryIntegrated(SystemModuleInformation akMod, Int aiSize = 0) Global 
;     If HTG:UtilityExt.IsNone(akMod)
;         return None
;     EndIf

;     If !akMod.IsCoreIntegrated
;         return FormDictionary(aiSize)
;     EndIf

;     FormDictionary res
;     res = _CreatedRegisteredDictionary(akMod, "HTG:Collections:FormDictionary", aiSize) as FormDictionary
;     LogObjectGlobal(res, "HTG:Collections:FormDictionary.FormDictionary(" + aiSize  + "): " + res)
;     return res
; EndFunction

Bool Function Initialize(Int aiSize = 0)
    If _isInitialized
        return False
    EndIf

    TryLockGuard _arrayGuard
        _internalArray = new KeyValuePair[aiSize]
        _trackedIndex = 0
        _count = 0
        _isInitialized = True
    EndTryLockGuard

    return True
EndFunction

Function Clear()
    If !_isInitialized
        return
    EndIf

    TryLockGuard _arrayGuard
        _internalArray.Clear()
        _count = 0
        _trackedIndex = 0
        _isInitialized = False
    EndTryLockGuard
EndFunction

Var Function GetKeyValue(Form akKey)
    Int i = Find(akKey)
    If i > -1
        KeyValuePair kPair = GetAt(i)
        return kPair.ValueForm
    EndIf
EndFunction

KeyValuePair Function GetPair(Form akKey)
    Int i = Find(akKey)
    If i > -1
        KeyValuePair kPair = GetAt(i)
        return kPair
    EndIf
EndFunction

KeyValuePair Function GetAt(Int index)
    If index < Count
        return _internalArray[index]
    EndIf

    return None
EndFunction

Int Function Add(Form akKey, Form akValue, Bool overrideExisting = False)
    If !_isInitialized || !TestKey(akKey) || !TestValue(akValue)
        return -1
    EndIf

    Int i = -1
    Int fI = Find(akKey)
    If fI > -1
        If !overrideExisting
            return fI
        EndIf

        i = fI
    EndIf

    KeyValuePair kPair = new KeyValuePair
    kPair.KeyForm = akKey
    kPair.ValueForm = akValue

    If i > -1
        _internalArray[i] = kPair
    Else
        i = _Add(kPair)
    EndIf

    LogObjectGlobal(akValue as ScriptObject, "Added item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddDictionary(FormDictionary akDictionary)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akDictionary.Count
        KeyValuePair kPair = akDictionary.GetAt(kI)
        If TestPair(kPair) 
            Int fI = Find(kPair.KeyForm)
            If fI < 0
                i = _Add(kPair)
            EndIf
        EndIf
    EndWhile

    LogObjectGlobal(akDictionary, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddArray(KeyValuePair[] akArray)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akArray.Length
        If TestPair(akArray[kI])
            KeyValuePair kPair = akArray[kI]
            Int fI = Find(kPair.KeyForm)
            If fI < 0
                _Add(kPair)
            EndIf
        EndIf
    EndWhile

    ; Clean()
    LogObjectGlobal(Self, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Remove(Form akKey)
    If !_isInitialized || !TestKey(akKey)
        return -1
    EndIf

    Int i = -1
    TryLockGuard _arrayGuard
        i = Find(akKey)
        If i > -1
            _internalArray.Remove(i)
            _trackedIndex -= 1
            _count -= 1
        EndIf
    EndTryLockGuard

    Sort()
    LogObjectGlobal(akKey as ScriptObject, "Removed item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Find(Form akKey)
    If !_isInitialized || !TestKey(akKey)
        return -1
    EndIf

    Int i = 0
    While i < _internalArray.Length
        KeyValuePair kPair = _internalArray[i]
        If !IsNone(kPair) && CompareType(kPair.KeyForm, akKey)
            return i
        EndIf
        i += 1
    EndWhile

    return -1
EndFunction

Bool Function Contains(Form akKey)
    If !IsNone(akKey) && Find(akKey) > -1
        return True
    EndIf

    return False
EndFunction

Int Function FindFirstEmpty()
    Int i = 0
    While i < _internalArray.Length
        If IsNone(_internalArray[i] as Var)
            return i
        EndIf

        i += 1
    EndWhile
    
    return -1
endFunction

Bool Function Sort(Int aiStartingIndex = 0)
    Bool bFirstNoneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < _internalArray.Length
        If IsNone(_internalArray[aiStartingIndex])
            If bFirstNoneFound == False
                bFirstNoneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstNoneFound == True
                If !IsNone(_internalArray[aiStartingIndex])
                    TryLockGuard _arrayGuard
                        _internalArray[iFirstNonePos] = _internalArray[aiStartingIndex]
                        _internalArray[aiStartingIndex] = None
                    EndTryLockGuard

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

    TryLockGuard _arrayGuard
        While i < _internalArray.Length
            If IsNone(_internalArray[i])
                _internalArray.Remove(i)
            EndIf
        EndWhile
    EndTryLockGuard

    Sort()
EndFunction

Bool Function IsNone(Var akValue)
    If akValue is ScriptObject
        return HTG:UtilityExt.IsNone(akValue as ScriptObject) 
    ElseIf akValue is KeyValuePair
        KeyValuePair kPair = akValue as KeyValuePair
        return kPair == None || IsNone(kPair.KeyForm) || IsNone(kPair.ValueForm)
    EndIf

    return False
EndFunction

; Bool Function IsPairNone(KeyValuePair akPair)
;     return IsNone(akPair) || \
;                 IsNone(akPair.KeyForm) || \
;                 IsNone(akPair.ValueForm)
; EndFunction

Bool Function TestPair(KeyValuePair akPair)
    If _internalArray.Length == 0
        return True
    EndIf

    return TestKey(akPair.KeyForm) && TestValue(akPair.ValueForm)
EndFunction

Bool Function TestType(Var akType1, Var akType2)
    return True
EndFunction

Bool Function TestValue(Form akValue)
    return True
EndFunction

Bool Function TestKey(Form akKey)
    return True
EndFunction

Bool Function CompareType(Form akArrayItem, Form akItem)
    return True
EndFunction

KeyValuePair[] Function GetArray()
    return _internalArray
EndFunction

String Function ToString()
    String res = "HTG:Collection:Dictionary:" + Self.GetFormID() + "\n" \
    + "\tHTG:Collection:Dictionary<" + KeyType + ", " + ValueType + ">\n" \
    + "\tHTG:Collection:Dictionary.Count:" + _count + "\n" \
    + "\tHTG:Collection:Dictionary.Array:" + _internalArray

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
        WaitExt(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isInitialized
EndFunction

Int Function _Add(KeyValuePair akPair)
    Int i = _internalArray.Length ; FindFirstEmpty()
    TryLockGuard _arrayGuard
        If _trackedIndex > -1 && _trackedIndex < _internalArray.Length
            _internalArray[_trackedIndex] = akPair
        Else
            If _internalArray.Length < _maxSize
                _internalArray.Add(akPair, 1)
                ; i = _internalArray.Length - 1
            EndIf
        EndIf
    EndTryLockGuard

    If _internalArray.Length > i
        _trackedIndex += 1
        _count += 1
        return _trackedIndex
    EndIf

    return -1
EndFunction

FormDictionary Function _CreateDictionary(SystemModuleInformation akMod, Int aiFormId = 0x00000834, Int aiSize = 0) Global
    Form kForm = CreateForm(aiFormId, akMod.FileName)
    If !HTG:UtilityExt.IsNone(kForm)
        FormDictionary kList = CreateReference(akMod, kform) as FormDictionary
        If !HTG:UtilityExt.IsNone(kList)
            kList.Enable(False)
            kList.Initialize(aiSize)
            return kList
        EndIf
    EndIf

    return None
EndFunction

FormDictionary Function _CreatedRegisteredDictionary(SystemModuleInformation akMod, String asListType, Int aiSize = 0) Global
    FormList kRegistry = akMod.CollectionRegistry
    Form kForm
    Int i 
    While i < kRegistry.GetSize()
        kForm = kRegistry.GetAt(i).CastAs(asListType) as Form
        If !HTG:UtilityExt.IsNone(kForm)
            i = kRegistry.GetSize()
        EndIf

        i += 1
    EndWhile

    If !HTG:UtilityExt.IsNone(kForm)
        FormDictionary kList = CreateReference(Game.GetPlayer(), kform) as FormDictionary
        If !HTG:UtilityExt.IsNone(kList)
            kList.Enable(False)
            kList.Initialize(aiSize)
            return kList
        EndIf
    EndIf

    return None
EndFunction