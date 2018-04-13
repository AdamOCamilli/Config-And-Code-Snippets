'''
Created on Apr 13, 2018

@author: Adam Camilli (aocamilli@wpi.edu)
'''

## This is the text editor interface. 
## Anything you type or change here will be seen by the other person in real time.

# all english words we can use
wordlist = ("a abet add adder ade an at ate bad bed beget bent bet beta bran dee deed did din dine dint due duet ease edit eel eft eh elf elite emu enter ere ere"
            " eta eve ewe fan fate fee feel fete fir fire he i idea in instep iran irate ire keen kilt kin kite lea lee lens lid met net nil peer pen pet pie plea poem rate reel rein"
            " saute senate sent set set skin stain step stun tea tear tee teen teeth test that tide tie tie tier tiet time tin tine tit tun ute vain vet wee weed weir"
            " welt west win wine wit with wits yet")
words = [word for word in wordlist.split(' ') if len(word) > 0] # make sure I haven't managed to get the empty string in as a word

# definition of morse code for english
letter2morse = {'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.', 'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---', 'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---', 'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-', 'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--', 'Z': '--..'}

# task: given a morse code string, give me all sentences it might translate to in english using the word list
# eg '.....' => [['he'], ['eh']]
# eg '..........' => [['he', 'eh'], ['eh', 'eh'], ['he', 'he'], ...]
# eg '.-.-' => [['a', 'a']]


# Longest number of morse symbols that can represent one letter
MAX_LETTER_MORSE = 4
# Length of longest word in wordlist
MAX_WORD_LEN = 6
# All possible sentences from a string of morse
sentences = [[]]

class Tree(object):
    def __init__(self,data):
        self.children = []
        self.data = data
        
    def toString(self, spaces):
        for i in range(spaces):
            print("| ",end='')
        if (len(self.children) > 0):
            print(self.data, '(', sep=' ', end='')
            for child in self.children:
                print(child.data, end='')
            print(')')
        else:
            print(self.data)
            return
        for child in self.children:
            child.toString(spaces + 1)
            
        
# Pick out all possible letters that can be formed
def firstLetters(morseStr):
    firsts = [] # List of chars
    # Get possible first letters
    for letter, morse in letter2morse.items():
        temp = morseStr[0:MAX_LETTER_MORSE]
        if (temp[0:len(morse)] == morse):
            firsts.append(letter)
            continue
    return sorted(firsts)

def firstLetterTree(tree,morseStr):
    if (len(firstLetters(morseStr)) > 0):
        for letter in firstLetters(morseStr):
            tree.children.append(Tree(letter))
    if (len(tree.children) > 0):
        for child in tree.children:
            firstLetterTree(child, morseStr[len(letter2morse.get(child.data)) : len(morseStr)])

def wordsFromNode(tree,word,words):
    print("Word:",word)
    if (tree.data in letter2morse.keys()):
        word += tree.data
    if (word in wordlist and words.count(word) == 0):
        words.append(word)
    if (len(tree.children) > 0):
        for child in tree.children:
            temp = word
            wordsFromNode(child,temp,words)
        
    
                 

morseStr = "-.---."
tree = Tree("~")
firstLetterTree(tree, morseStr)


print(tree.toString(0))
word = ""
words = []
print(wordsFromNode(tree,word,words))
