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
    Public deptno

    '��̎Ј��ڍ׏��
    Public emptyEmp

End Class
' ViewModel�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function ViewModelPropNames()
    ViewModelPropNames = Array("title", "departments", "employees", "empno", "deptno", "emptyEmp")
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

Dim vm
Call Main

Sub Main
    Set vm = New ViewModel

    Call LoadViewModel(vm)

    Call RenderHTML(vm)
End Sub

Function LoadViewModel(vm)
    '�^�C�g���̐ݒ�
    vm.title = "ArrayList��SqlQuery���g�����T���v��(Vue+Ajax��)"

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

    '�Ј����X�g�̏�����
    Set vm.employees = New ArrayList

    '��̎Ј��ڍ׏��̏�����
    Set vm.emptyEmp = New Emp

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
            <select class="form-control" name="deptno" id="deptno" v-model="deptno" v-on:change="loadEmployees">
                <option v-for="dept in departments" v-bind:value="dept.deptno">{{dept.deptname}}</option>
            </select>
        </div>

        <div class="form-group">
            <label for="empno">�Ј�</label>
            <select class="form-control" name="empno" id="empno" v-model="empno">
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
<script src="https://cdnjs.cloudflare.com/ajax/libs/axios/0.18.0/axios.js"></script>
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
        data() {
            return model;
        },
        computed : {
            empDetail(){
                let emp = this.employees.length > 0 ? this.employees.filter(item => item.empno == vm.empno )[0] : null;
                if (!emp) emp = this.emptyEmp;
                return emp;
            }
        },
        methods : {
            loadEmployees(event) {
                axios
                    .get("sample_emp_json.asp?deptno=" + this.deptno)
                    .then(function(response){
                        vm.empno = response.data.employees ? response.data.employees[0].empno : null;
                        vm.employees = response.data.employees;
                    })
                    .catch(function(error){
                        alert()
                    });
            },
        },

        mounted(){
            this.loadEmployees();
        },

    }).mount("#app");

</script>

</body>
</html>
<%
End Function
%>