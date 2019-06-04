function toggleMenu (objID)
{
    if (document.getElementById (objID).style.display != "block")
   {
        document.getElementById (objID).style.display = "block";
        document.getElementById ('togglelink').innerHTML = "[ fewer options ]";
    }
    else
    {
        document.getElementById (objID).style.display = "none";
        document.getElementById ('togglelink').innerHTML = "[ more options ]";
     }
}
