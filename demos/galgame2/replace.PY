from re import *
fr=open("result.txt","w")
#ft=open("translate.txt","r")
fo=open("origin.txt","r")
result = ""
id = 0
#time =0
name="~"
nf=False
append=False
fr.write("\tCHS_NAME\tCHS\n")
fr.write("RESERVED_SYMBOL\t\t\n")
while True:
    #result =""
    oline = fo.readline().decode('utf-8')
    if not oline:
        #文件尾
        break
    if search(r'\[processname text=.*\]',oline):
        #姓名设置
        newname=search(r'\[processname text=(.*)\]',oline).group(1)
        if newname==name:
            #没有变化
            nf=False
        else:
            #变化了
            nf=True
            name=newname
    elif search(r"^[^\x00-\xff]",oline):
        #tline = ft.readline().decode('utf-8')
        if search(r'.*\[l\]\[r\]',oline):
            oline=search(r'(.*)\[l\]\[r\]',oline).group(1)+'\\n'
            append=False
        elif search(r'.*\[p\]',oline):
            oline=search(r'(.*)\[p\]',oline).group(1)+r'#'
            append=True
        if append==True and not search("T",result):
            result="TEXT_"+str(id)+"\t"+name+"\t"+result+oline
        else:
            result+=oline
    elif match(";.*",oline) or match("\n",oline):
        pass
    else:
        if name=="~":
            pass
        else:
            nf=True
    if nf and append:
        fr.write(result[:-1].encode("utf-8"))
        if result:
            fr.write('\n')
            id+=1
            result=""
fr.close()

