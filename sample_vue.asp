<% 
Option Explicit
%>
<!--#include file="./aspvbslib/adovbs.inc"-->
<!--#include file="./aspvbslib/aspvbslib-core.inc"-->
<!--#include file="./aspvbslib/aspvbslib-data.inc"-->
<!--#include file="./aspvbslib/aspvbslib-web.inc"-->
<%
' ViewModel�N���X
Class ViewModel
    '�^�C�g��
    Public title
    '�������X�g
    Public departments
    '�Ј����X�g
    Public employees
    '�I�𒆂̎Ј��ԍ�
    Public empno
    '�I�𒆂̕����ԍ�
    public deptno
    '�I�𒆂̎Ј�����
    Public empDetail
End Class
' ViewModel�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function ViewModelPropNames()
    ViewModelPropNames = Array("title", "departments", "employees", "empno", "deptno", "empDetail")
End Function

'�Ј��N���X
Class Emp 
    '�Ј��ԍ�
    Public empno
    '�Ј���
    Public empname
    '�����ԍ�
    Public deptno
    '����
    Public description
End Class
' Emp�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function EmpPropNames()
    EmpPropNames = Array("empno", "empname", "deptno", "description")
End Function

'�����N���X
Class Dept
    '�����ԍ�
    Public deptno
    '������
    Public deptname
End Class
' Dept�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function DeptPropNames()
    DeptPropNames = Array("deptno", "deptname")
End Function

Dim vm
Call Main

Sub Main
    Set vm = New ViewModel

    Call LoadViewModel(vm)

    Call RenderHTML(vm)
End Sub

Function LoadViewModel(vm)
    '�^�C�g���̐ݒ�
    vm.title = "ArrayList��SqlQuery���g�����T���v��(Vue��)"

    '���N�G�X�g�̎擾
    vm.deptno = NullValue(Request("deptno"), "")
    If Len(vm.deptno) > 0 And ChkNum(vm.deptno) Then
        vm.deptno = CInt(vm.deptno)
    Else
        vm.deptno = ""
    End If

    vm.empno = NullValue(Request("empno"), "")
    If Len(vm.empno) > 0 And ChkNum(vm.empno) Then
        vm.empno = CInt(vm.empno)
    Else
        vm.empno = ""
    End If

    '�f�[�^�x�[�X�ڑ�
    Dim DbConn
    Set DbConn = Server.CreateObject("ADODB.Connection")
    Dim dbfilepath :dbfilepath = Server.MapPath("aspvbslib_sample.mdb")
    dim dbconnString :dbconnString = "Driver={Microsoft Access Driver (*.mdb)}; DBQ=" & dbfilepath & ";"
    DbConn.Open dbconnString

    '�������X�g�̎擾
    Set vm.departments = SqlQuery(DbConn, "Dept", "SELECT * FROM dept")
    if IsNullOrEmpty(vm.deptno) And vm.departments.Count > 0 Then
        vm.deptno = vm.departments(0).deptno
    End If
    
    '�Ј����X�g�̎擾�i�����w��j
    Dim cmd: Set cmd = Server.CreateObject("ADODB.Command")
    cmd.CommandText = "SELECT * FROM emp WHERE deptno=?"
    cmd.parameters.Append cmd.CreateParameter("@deptno", adInteger, adParamInput, , vm.deptno)
    Set vm.employees = SqlQuery(DbConn, "Emp", cmd)

    '�I�𒆂�empno�����݂��Ȃ���΁A���݂̃��X�g�̐擪��I������B
    If vm.employees.Where("item.empno = p", vm.empno).Count = 0 Then
        If vm.employees.Count > 0 Then
            vm.empno = vm.employees(0).empno
        Else
            vm.empno = ""
        End If
    End If

    '�I�𒆂̎Ј���񖾍ׂ�ݒ�
    If vm.empno = "" Then
        '�I������Ă��Ȃ���Ώ�����
        Set vm.empDetail = New Emp
    Else
        Set vm.empDetail = vm.employees.FindFirst("item.empno = p", vm.empno)(0)
    End If

    DbConn.Close
    Set DbConn = Nothing

End Function

Function RenderHTML(vm)
%>
<!doctype html>
<html lang="jp">
<head>
    <meta charset="shift-jis">
    <title><%=vm.title%></title>
    <meta name="description" content="Sample 01">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">  
    <style>
        [v-cloak] {
            display: none;
        }
    </style>
</head>
<body>
<div id="app" class="container" v-cloak>
    <h4>{{ title }}</h4>
    <form>
        <div class="form-group">
            <label for="deptno">����</label>
            <select class="form-control" name="deptno" id="deptno" v-model="deptno" onchange="this.form.submit()">
                <option v-for="dept in departments" v-bind:value="dept.deptno">{{dept.deptname}}</option>
            </select>
        </div>

        <div class="form-group">
            <label for="empno">�Ј�</label>
            <select class="form-control" name="empno" id="empno" v-model="empno" onchange="this.form.submit()">
                <option v-for="emp in employees" v-bind:value="emp.empno">{{emp.empname}}</option>
            </select>
        </div>

        <div class="form-group">
            <label>�ڍ�</label>
            <div class="card p-3" style="width:18rem">
                <h5 class="card-title">{{empDetail.empname}}</h5>
                <p class="card-text">{{empDetail.description}}
                </p>
            </div>
        </div>
    </form>
</div>

<script src="https://unpkg.com/vue@next"></script>
<script type="text/javascript">
    
    var baseVM = {
        data : function() {
            return {
            }
        },
        methods: {
        }
    }
    
    var model = <%=JSONValue(vm)%>;
    
    var vm = Vue.createApp({
        mixins: [baseVM],
        data : function() {
            return model;
        },
        methods : {
        
        }
    }).mount("#app");

</script>

</body>
</html>
<%
End Function
%>