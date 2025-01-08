Scriptname HTG:Collections:List extends ObjectReference
import HTG
import HTG:SystemLogger
import HTG:IntUtility

String Property ArrayType = "Var" Auto Hidden

Int Property Count Hidden
    Int Function Get()
        return _count
    EndFunction
EndProperty

Var[] Property _Array Hidden
    Var[] Function Get()
        return _internalArray
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _arrayGuard ProtectsFunctionLogic
Var[] _internalArray
Bool _isInitialized
Int _count = 0
Int _maxSize = 128 Const

List Function List(Int aiSize = 4) Global 
    List res = HTG:Collections:List._CreateReference(_CreateForm(), aiSize) as List
    res.Enable(False)
    res.Initialize(aiSize)
EndFunction

Form Function _CreateForm(Int aiFormId = 0x00000817, String modName = "HTG-Regenesys-Core") Global
    Form aForm = Game.GetFormFromFile(aiFormId, modName + ".esp")
    HTG:SystemLogger.LogObjectGlobal(aForm, "HTG:Collections:List._CreateForm(" + aiFormId + ", " + modName + ".esp): " + aForm)
    If aForm == None
        aForm = Game.GetFormFromFile(aiFormId, modName + ".esm") 
        HTG:SystemLogger.LogObjectGlobal(aForm, "HTG:Collections:List._CreateForm(" + aiFormId + ", " + modName + ".esm): " + aForm)
    EndIf

    return aForm
EndFunction

ObjectReference Function _CreateReference(Form akForm, Int aiSize = 4) Global
    If akForm != None ;;&& akForm is List
        ObjectReference ref = Game.GetPlayer().PlaceAtMe(akForm, abInitiallyDisabled = True, abDeleteWhenAble = False)
        HTG:SystemLogger.LogObjectGlobal(ref, "HTG:Collections:List._CreateReference(" + akForm + ", " + aiSize  + "): " + ref)
        return ref
    EndIf

    return None
EndFunction

Bool Function Initialize(Int aiSize = 4)
    If _isInitialized
        return False
    EndIf

    LockGuard _arrayGuard
        _internalArray = new Var[aiSize]
        _isInitialized = True
    EndLockGuard

    return True
EndFunction

Function Clear()
    If !_isInitialized
        return
    EndIf

    LockGuard _arrayGuard
        _internalArray.Clear()
        _count = 0
        _isInitialized = False
    EndLockGuard
EndFunction

Var Function GetVarAt(Int index)
    return _internalArray[index]
EndFunction

Int Function Add(Var akItem, Bool overrideExisting = False)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    Int fI = Find(akItem)
    If !overrideExisting && fI > -1
        return fI
    EndIf

    Int i = -1
    LockGuard _arrayGuard
        i = FindFirstEmpty()
        If i > -1
            _internalArray[i] = akItem
            _count += 1
        EndIf

        If _internalArray.Length < _maxSize
            _internalArray.Add(akItem, 1)
            _count += 1
            i = _internalArray.Length
        EndIf
    EndLockGuard

    LogObjectGlobal(akItem as ScriptObject, "Added item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Remove(Var akItem)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    Int i = -1
    LockGuard _arrayGuard
        i = Find(akItem)
        If i > -1
            _internalArray.Remove(i)
            _count -= 1
        EndIf
    EndLockGuard

    LogObjectGlobal(akItem as ScriptObject, "Removed item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Find(Var akItem)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    Int i = 0
    While i < _internalArray.Length
        If CompareItems(_internalArray[i], akItem)
            return i
        EndIf
        i += 1
    EndWhile

    return -1
EndFunction

Int[] Function FindAll(Var akItem)
    Int i = 0
    Int[] resArray = new Int[0]

    While i < Count
        If !IsNone(_internalArray[i])
            If CompareItems(_internalArray[i], akItem)
                resArray.Add(i, 1)
            EndIf
        EndIf

        i += 1
    EndWhile

    If resArray.Length > 0
        IArrayClean(resArray)
    EndIf

    return resArray
EndFunction

Bool Function Contains(Var akItem)
    If Find(akItem) > -1
        return True
    EndIf

    return False
EndFunction

Int Function FindFirstEmpty()
    Int i = 0
    While i < _internalArray.Length
        If IsNone(_internalArray[i])
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
                    LockGuard _arrayGuard
                        _internalArray[iFirstNonePos] = _internalArray[aiStartingIndex]
                        _internalArray[aiStartingIndex] = None
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

; Function Resize(Int amount)
;     Int i = 0
;     Int count = _internalArray.Length
;     Int newSize = _internalArray.Length + amount
;     Var[] resArray = new Var[newSize]
    
;     If newSize < count
;         count = newSize
;     EndIf

;     While i < count
;         resArray[i] = array[i]
;     EndWhile

;     LockGuard _arrayGuard
;         resArray = array
;     EndLockGuard
; EndFunction

Function Clean()
    Int i = 0
    ; Sort()

    LockGuard _arrayGuard
        While i < _internalArray.Length
            If IsNone(_internalArray[i])
                _internalArray.Remove(i)
            EndIf
        EndWhile
    EndLockGuard

    Sort()
EndFunction

Bool Function IsNone(Var akItem)
    return False
EndFunction

Bool Function TestType(Var akItem)
    If _internalArray.Length == 0
        return True
    EndIf

    Var kArrayItem = _internalArray[0]
    If kArrayItem as Bool && akItem as Bool
        return True
    ElseIf kArrayItem as Int && akItem as Int
        return True
    ElseIf kArrayItem as Float && akItem as Float
        return True
    ; ElseIf kArrayItem as Array && akItem as Array
    ;     return akArrayItem as Array == akItem as Array
    ; ElseIf kArrayItem as Struct
    ElseIf kArrayItem as ScriptObject && akItem as ScriptObject
        return True
    EndIf

    return False
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
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

String Function ToString()
    String res = "HTG:Collection:List:" + Self.GetFormID() + "\n" \
    + "\tHTG:Collection:List<" + ArrayType + ">\n" \
    + "\tHTG:Collection:List.Count:" + _count + "\n" \
    + "\tHTG:Collection:List.Array:" + _internalArray

    return res
EndFunction

Function WaitForInitialized()
    If IsInitialized
        return
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 50
    Bool maxCycleHit
    While !maxCycleHit && !IsInitialized
        Utility.Wait(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile
EndFunction