unit UTreeView;

interface

Uses ComCtrls,Classes,Controls,Dialogs,ExtCtrls,StdCtrls,SysUtils;

Procedure AddFileInTreeView(AListFile : TStrings);
Procedure AddCommentInTreeView(AText : string; AIndex : Integer);
Procedure DelInTreeView;
Procedure MoveFileInTreeView (ACNode :TTreeNode; X,Y : Integer);

implementation

Uses Principal,UImageAndComments;

{>>ADDITION D'UN FICHIER DANS LE TREEVIEW}
Procedure AddFileInTreeView(AListFile : TStrings);
Var
  CNode:TTreeNode;
  NmFile : LongInt;
Begin
With Main.ImageFiles_TreeView do
  Begin
  {On d�finir le TreeNode en cas de TreeView vide, sinon si pas vide}
  IF selected=nil then  CNode:=selected Else 
    Begin
	{Si la s�lection n'est pas un fichier on sort}
    If Selected.ImageIndex<>0 then Exit  
	{Sinon le TreeNode est le prochain TreeNode "fr�re"}
    Else CNode:=selected.getNextSibling; 
    End;
	{On fait une boucle avec tout les fichiers s�lectionn�s (rappel on est en multis�lection)}
    For NmFile:=0 to(AListFile.Count-1) do 
      Begin
	  {On d�finit l'icone}
      Images:=Main.ImageList1; 
	  {On insert le nom du fichier dans le TreeNode}
      Items.insert(CNode, AListFile[NmFile]); 
      End;
    End;
End;

{>>ADDITION D'UN COMMENTAIRE DANS LE TREEVIEW}
Procedure AddCommentInTreeView(AText : string; AIndex : Integer);
Var
  NumChildren : integer;
  ACNode : TTreeNode;
Begin
{On d�finit le TreeNode}
ACNode:=Main.ImageFiles_TreeView.Selected;
{Si ce n'est pas un fichier Image on sort}
If ACNode.ImageIndex<>0 then Exit;
{On fait une boucle}
For NumChildren:=0 to (ACNode.Count-1) do
{Si il ya deja un commentaire de ce type on sort}
If ACNode.Item[NumChildren].ImageIndex=AIndex then Exit;
{On l'additionne au TreeNode en tant qu'enfant}
ACNode:=Main.ImageFiles_TreeView.Items.AddChild(ACNode, AText);
Main.ImageFiles_TreeView.Images:=Main.ImageList1;
{On d�finit son icone}
ACNode.ImageIndex:=AIndex;
End;

{>>SUPPRESSION D'UNE S�LECTION DANS LE TREEVIEW}
Procedure DelInTreeView;
Var
  CNode : TTreeNode;
  NumChildren : Integer;
Begin
With Main.ImageFiles_TreeView.Selected do
  Begin
    IF ImageIndex=2 then Exit;
    {Si on s�lectionne un commentaire textuel}
    If ImageIndex=1 then
    begin
    {Le TreeNode est son parent}
    CNode:=Parent;
    {On d�cr�mente sinon beug}
    For NumChildren:=(CNode.Count-1)  downto 0 do
    {Si il ne s'agit pas d'un commentaire audio on le supprime}
    If CNode.Item[NumChildren].ImageIndex<>3 then CNode.Item[NumChildren].Delete;
    End
  {sinon on supprime le TreeNode et les enfants}  
  Else delete;
  End;
End;

{>>DEPLACEMENT D'UNE SELECTION DE TYPE IMAGE DANS LE TREEVIEW}
Procedure MoveFileInTreeView (ACNode :TTreeNode; X,Y : Integer);
Var
  NewCNode,ChildrenCNode : TTreeNode;
  NumChildren : integer;
begin
{On d�finit le TreeNode de destination}
NewCNode:=Main.ImageFiles_TreeView.GetNodeAt(X,Y);
{On ins�re le TreeNode source vers le TreeNode de destination}
NewCNode:=Main.ImageFiles_TreeView.Items.Insert(NewCNode,ACNode.text);
{on d�finit son icone}
NewCNode.ImageIndex:=0;
{On fait une boucle}
For NumChildren:=0 to (ACNode.Count-1) do
  Begin
  {On additionne les enfants du TreeNode source vers le TreeNode de destination}
  ChildrenCNode:=Main.ImageFiles_TreeView.Items.AddChild(NewCNode,ACNode.Item[NumChildren].text);
  {On d�finit leurs images}
  ChildrenCNode.ImageIndex:=ACNode.Item[NumChildren].ImageIndex;
  End;
{On supprime le TreeNode Source et ses enfants}
ACNode.delete;
End;

end.
 